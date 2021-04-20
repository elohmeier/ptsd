#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.python-telegram-bot python3Packages.requests
# pylint: disable=C0116

import argparse
import base64
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


# Define a few command handlers. These usually take the two arguments update and
# context. Error handlers also receive the raised TelegramError object in error.
def start(update: Update, _: CallbackContext) -> None:
    update.message.reply_text("Hi! Use /set <seconds> to set a timer")


def impfcode_alarm(context: CallbackContext) -> None:
    """Send the alarm message."""
    job = context.job

    try:
        res = requests.get(
            "https://353-iz.impfterminservice.de/rest/suche/termincheck?plz=20357&leistungsmerkmale=L920,L921,L922",
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
        context.bot.send_message(job.context, text=f"alarm failed: {ex}")


def termin_alarm_factory(impfcode: str):
    def alarm(context: CallbackContext) -> None:
        job = context.job

        try:
            res = requests.get(
                "https://353-iz.impfterminservice.de/rest/suche/impfterminsuche?plz=20357",
                headers={
                    "Authorization": "Basic %s"
                    % base64.encodebytes(b":%s" % impfcode.encode()).decode().strip(),
                    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36",
                },
                timeout=3,
            )

            if res.status_code == 200:
                nothing_available = {
                    "gesuchteLeistungsmerkmale": ["L920", "L921"],
                    "termine": [],
                    "termineTSS": [],
                    "praxen": {},
                }
                if res.json() != nothing_available:
                    context.bot.send_message(job.context, text=res.json())
            else:
                context.bot.send_message(
                    job.context, text=f"{res.status_code}: {res.content}"
                )

        except Exception as ex:
            context.bot.send_message(job.context, text=f"alarm failed: {ex}")

    return alarm


def remove_job_if_exists(name: str, context: CallbackContext) -> bool:
    """Remove job with given name. Returns whether job was removed."""
    current_jobs = context.job_queue.get_jobs_by_name(name)
    if not current_jobs:
        return False
    for job in current_jobs:
        job.schedule_removal()
    return True


def set_timer(update: Update, context: CallbackContext) -> None:
    """Add a job to the queue."""
    if update.message is None:
        return

    chat_id = update.message.chat_id
    try:
        # args[0] should contain the time for the timer in seconds
        interval = int(context.args[0])
        impfcode = context.args[1]
        if interval < 0:
            update.message.reply_text("Sorry we can not go back to future!")
            return

        if re.match(r"^\w{4}-\w{4}-\w{4}$", impfcode) is None:
            update.message.reply_text("Sorry, invalid impfcode!")
            return

        job_removed = remove_job_if_exists(str(chat_id), context)
        context.job_queue.run_repeating(
            termin_alarm_factory(impfcode),
            interval=interval,
            first=3,
            context=chat_id,
            name=str(chat_id),
        )

        text = "Timer successfully set!"
        if job_removed:
            text += " Old one was removed."
        update.message.reply_text(text)

    except (IndexError, ValueError):
        update.message.reply_text("Usage: /set <seconds>")


def unset(update: Update, context: CallbackContext) -> None:
    """Remove the job if the user changed their mind."""
    chat_id = update.message.chat_id
    job_removed = remove_job_if_exists(str(chat_id), context)
    text = (
        "Timer successfully cancelled!" if job_removed else "You have no active timer."
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
    dispatcher.add_handler(CommandHandler("set", set_timer))
    dispatcher.add_handler(CommandHandler("unset", unset))

    # Start the Bot
    updater.start_polling()

    # Block until you press Ctrl-C or the process receives SIGINT, SIGTERM or
    # SIGABRT. This should be used most of the time, since start_polling() is
    # non-blocking and will stop the bot gracefully.
    updater.idle()


if __name__ == "__main__":
    main()
