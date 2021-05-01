#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.python-telegram-bot python3Packages.requests python3Packages.pyyaml
# pylint: disable=C0116

import argparse
import logging
import re
import requests
import yaml

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
    update.message.reply_text("Hi! Use /set <seconds> to set a timer")


def alarm(context: CallbackContext) -> None:
    """Send the alarm message."""
    job = context.job

    try:
        base_url = "https://impftermine.minden-luebbecke.de"
        resi = requests.get(base_url, timeout=3)
        n_url = next(
            re.finditer(
                r'"(https://impftermine.minden-luebbecke.de/m/iml/extern/calendar/\?uid=[a-z0-9-]+)"',
                resi.text,
            )
        ).group(1)
        resii = requests.head(n_url, timeout=3)
        nn_url = base_url + resii.headers["Location"]
        resiii = requests.post(
            nn_url,
            data={
                "action_type": "next_step",
                "step_active": "3",
                "services": "",
                "locations": ["de9f2ff6-54c6-4aac-a02f-39954e3f5c6c"],
                "plz": "",
                "q1": "on",
                "q2": "on",
                "q3": "on",
                "q4": "on",
                "q5": "on",
                "q6": "on",
                "services": "3a6a752e-7084-41e8-be5e-d350115706ef",
                "service_3a6a752e-7084-41e8-be5e-d350115706ef_amount": "1",
                "weekdays": [1, 2, 3, 4, 5, 6, 0],
                "time_ranges": ["0-720"],
                "appointments_from": "2021-05-01",
            },
            timeout=3,
        )
        m = next(
            re.finditer(
                r'<!-- APPOINTMENT LIST -->.+var pA = ("nothing_Found"|.+);.+function addDate\(dates,appointment\){',
                resiii.text,
                re.MULTILINE | re.DOTALL,
            )
        )
        yml_data = m.group(1)

        if yml_data == '"nothing_Found"':
            return

        parsed_yml_data = yaml.load(yml_data.replace("\t", ""))

        new_appointments = [
            a["date_time"]
            for a in parsed_yml_data["appointments"]
            if a["date_time"] not in TERMINE
        ]
        TERMINE.extend(new_appointments)

        if len(new_appointments) > 0:
            context.bot.send_message(
                job.context, text="Neue Termine:\r\n" + "\r\n".join(new_appointments)
            )
    except Exception as ex:
        context.bot.send_message(job.context, text=f"alarm failed: {ex}")


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
    chat_id = update.message.chat_id
    try:
        # args[0] should contain the time for the timer in seconds
        due = int(context.args[0])
        if due < 0:
            update.message.reply_text("Sorry we can not go back to future!")
            return

        job_removed = remove_job_if_exists(str(chat_id), context)
        context.job_queue.run_once(alarm, due, context=chat_id, name=str(chat_id))

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
