# this file is used as a imap-filter command in the maddy configuration
# https://maddy.email/man/_generated_maddy-imap.5/#system-command-filter-imapfiltercommand
# https://maddy.email/man/_generated_maddy-filters.5/#system-command-filter-checkcommand
import argparse

# folder needs to be existent or maddy will deliver it to the INBOX
sender_folder_map = {
    "events@digitalcluster.hamburg": "Newsletter",
    "newsletter@digitalcluster.hamburg": "Newsletter",
    "noreply@mail.bloombergview.com": "Newsletter",
}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--account_name")
    parser.add_argument("--sender")
    args = parser.parse_args()

    if args.account_name == "enno@nerdworks.de":
        if args.sender in sender_folder_map:
            print(sender_folder_map[args.sender])
