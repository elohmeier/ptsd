#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.python-telegram-bot python3Packages.requests
# pylint: disable=C0116

import argparse
import base64
import datetime
import logging
import re
import requests
from telegram import Update
from telegram.ext import Updater, CommandHandler, CallbackContext

# Enable logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)

logger = logging.getLogger(__name__)


TERMINE = []


# Define a few command handlers. These usually take the two arguments update and
# context. Error handlers also receive the raised TelegramError object in error.
def start(update: Update, _: CallbackContext) -> None:
    update.message.reply_text(
        """
Hi! Folgende Kommandos sind möglich:

-- Suche nach Vermittlungscode --
/set_impfcode <seconds> <plz>
/unset_impfcode

-- Suche nach Termin mit vorhandenem Vermittlungscode --
/set_termin <seconds> <plz> <vermittlungscode>
/unset_impfcode

<seconds> z.B. auf 800 einstellen und für die 
<plz> im Webbrowser schauen, welche benutzt wird für das Impfzentrum.
        """
    )


def impfcode_alarm_factory(plz: str):
    def alarm(context: CallbackContext) -> None:
        """ sucht ohne Vermittlungscode nach Terminen, damit man einen Vermittlungscode bekommen kann """
        job = context.job

        try:
            res = requests.get(
                f"https://353-iz.impfterminservice.de/rest/suche/termincheck?plz={plz}&leistungsmerkmale=L920,L921,L922",
                headers={
                    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36",
                },
                timeout=3,
            )

            if res.status_code != 429:  # usual response: too many requests
                context.bot.send_message(
                    job.context, text=f"{res.status_code}: {res.json()}"
                )
        except Exception as ex:
            context.bot.send_message(job.context, text=f"impfcode-alarm failed: {ex}")

    return alarm


def termin_alarm_factory(impfcode: str, plz: str):
    """ Sucht zu einem vorhandenen Vermittlungscode Termine """

    def alarm(context: CallbackContext) -> None:
        job = context.job

        try:
            res = requests.get(
                f"https://353-iz.impfterminservice.de/rest/suche/impfterminsuche?plz={plz}",
                headers={
                    "Authorization": "Basic %s"
                    % base64.encodebytes(b":%s" % impfcode.encode()).decode().strip(),
                    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36",
                },
                timeout=3,
            )

            if res.status_code == 200:
                res_data = res.json()
                termine = [
                    [datetime.datetime.fromtimestamp(s["begin"] // 1000) for s in p]
                    for p in res_data["termine"]
                ]

                for t in termine:
                    if t not in TERMINE:
                        TERMINE.append(t)
                        context.bot.send_message(
                            job.context,
                            text=f"Neues Terminpaar: {t[0]:%d.%m.%Y %H:%M} und {t[1]:%d.%m.%Y %H:%M}",
                        )
            else:
                context.bot.send_message(
                    job.context, text=f"{res.status_code}: {res.content}"
                )

        except Exception as ex:
            context.bot.send_message(job.context, text=f"termin-alarm failed: {ex}")

    return alarm


def remove_job_if_exists(name: str, context: CallbackContext) -> bool:
    """Remove job with given name. Returns whether job was removed."""
    current_jobs = context.job_queue.get_jobs_by_name(name)
    if not current_jobs:
        return False
    for job in current_jobs:
        job.schedule_removal()
    return True


def set_impfcode_timer(update: Update, context: CallbackContext) -> None:
    """Add a job to the queue."""
    if update.message is None:
        return

    chat_id = update.message.chat_id
    try:
        # args[0] should contain the time for the timer in seconds
        interval = int(context.args[0])
        plz = context.args[1]
        if interval < 0:
            update.message.reply_text("Sorry we can not go back to future!")
            return

        job_removed = remove_job_if_exists(f"{chat_id}-impfcode", context)
        context.job_queue.run_repeating(
            impfcode_alarm_factory(plz),
            interval=interval,
            first=3,
            context=chat_id,
            name=f"{chat_id}-impfcode",
        )

        text = "impfcode timer successfully set!"
        if job_removed:
            text += " Old one was removed."
        update.message.reply_text(text)

    except (IndexError, ValueError):
        update.message.reply_text("Usage: /set_impfcode <seconds> <plz>")


def unset_impfcode(update: Update, context: CallbackContext) -> None:
    """Remove the job if the user changed their mind."""
    chat_id = update.message.chat_id
    job_removed = remove_job_if_exists(f"{chat_id}-impfcode", context)
    text = (
        "impfcode timer successfully cancelled!"
        if job_removed
        else "You have no active timer."
    )
    update.message.reply_text(text)


def set_termin_timer(update: Update, context: CallbackContext) -> None:
    """Add a job to the queue."""
    if update.message is None:
        return

    chat_id = update.message.chat_id
    try:
        # args[0] should contain the time for the timer in seconds
        interval = int(context.args[0])
        plz = context.args[1]
        impfcode = context.args[2]
        if interval < 0:
            update.message.reply_text("Sorry we can not go back to future!")
            return

        if re.match(r"^\w{4}-\w{4}-\w{4}$", impfcode) is None:
            update.message.reply_text("Sorry, invalid impfcode!")
            return

        job_removed = remove_job_if_exists(f"{chat_id}-termin", context)
        context.job_queue.run_repeating(
            termin_alarm_factory(impfcode, plz),
            interval=interval,
            first=3,
            context=chat_id,
            name=f"{chat_id}-termin",
        )

        text = "termin timer successfully set!"
        if job_removed:
            text += " Old one was removed."
        update.message.reply_text(text)

    except (IndexError, ValueError):
        update.message.reply_text(
            "Usage: /set_termin <seconds> <plz> <vermittlungscode>"
        )


def unset_termin(update: Update, context: CallbackContext) -> None:
    """Remove the job if the user changed their mind."""
    chat_id = update.message.chat_id
    job_removed = remove_job_if_exists(f"{chat_id}-termin", context)
    text = (
        "termin timer successfully cancelled!"
        if job_removed
        else "You have no active timer."
    )
    update.message.reply_text(text)


def main() -> None:
    """Run bot."""

    parser = argparse.ArgumentParser()
    parser.add_argument("token")
    args = parser.parse_args()

    # Create the Updater and pass it your bot's token.
    updater = Updater(args.token)

    # Get the dispatcher to register handlers
    dispatcher = updater.dispatcher

    # on different commands - answer in Telegram
    dispatcher.add_handler(CommandHandler("start", start))
    dispatcher.add_handler(CommandHandler("help", start))
    dispatcher.add_handler(CommandHandler("set_impfcode", set_impfcode_timer))
    dispatcher.add_handler(CommandHandler("unset_impfcode", unset_impfcode))
    dispatcher.add_handler(CommandHandler("set_termin", set_termin_timer))
    dispatcher.add_handler(CommandHandler("unset_termin", unset_termin))

    # Start the Bot
    updater.start_polling()

    # Block until you press Ctrl-C or the process receives SIGINT, SIGTERM or
    # SIGABRT. This should be used most of the time, since start_polling() is
    # non-blocking and will stop the bot gracefully.
    updater.idle()


if __name__ == "__main__":
    main()
