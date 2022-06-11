#!/usr/bin/env python3

import argparse
import requests

FN_SCAN = "7"
FT_PDF = "0"
Q_COL150 = "0"
Q_COL300 = "1"
Q_COL600 = "2"
Q_BW200 = "3"
Q_BW200_100 = "4"
Q_GRAY100 = "5"
Q_GRAY200 = "6"
Q_GRAY300 = "7"


class Client:
    def __init__(self, printer_ip, printer_password):
        self.printer_ip = printer_ip
        self.printer_password = printer_password
        self.ftp_ip = "192.168.178.37"

    def cfg(
        self,
        profile_num,
        profile_name,
        ftp_user,
        ftp_password,
        filename,
        quality,
        filetype,
    ):
        data = {
            "ProfileName": profile_name,
            "HostAddress": self.ftp_ip,
            "Username": ftp_user,
            "Scan2FtpPassword": ftp_password,
            "StoreDirectory": "/",
            "Scan2FtpFileName": filename,
            "Scan2FtpQuality": quality,
            "Scan2FtpFileType": filetype,
            "PassiveMode": "1",
            "PortNumber": "21",
        }

        res = requests.post(
            f"http://{self.printer_ip}/admin/profile_settings.html?id=scantoftp&val={profile_num}",
            auth=("admin", self.printer_password),
            data={f"{k}{profile_num}": v for k, v in data.items()},
        )
        if res.status_code != 200:
            raise Exception(f"Failed to configure profile {profile_num}")
        print("Profile", profile_name, "configured")


def main():
    parser = argparse.ArgumentParser(
        description="Update MFC7440N Scan2FTP configuration"
    )
    parser.add_argument("--printer-ip", default="192.168.178.33")
    parser.add_argument("--printer-pw", default="access")
    parser.add_argument("--ftp-pw-luisa", required=True)
    parser.add_argument("--ftp-pw-enno", required=True)
    args = parser.parse_args()

    c = Client(
        printer_ip=args.printer_ip,
        printer_password=args.printer_pw,
    )

    pw_l = args.ftp_pw_luisa
    pw_enno = args.ftp_pw_enno

    c.cfg(
        1,
        "LUISA gray-300",
        "luisa",
        pw_l,
        FN_SCAN,
        Q_GRAY300,
        FT_PDF,
    )
    c.cfg(2, "LUISA sw-200", "luisa", pw_l, FN_SCAN, Q_BW200, FT_PDF)
    c.cfg(
        3,
        "LUISA color-300",
        "luisa",
        pw_l,
        FN_SCAN,
        Q_COL300,
        FT_PDF,
    )
    c.cfg(
        4,
        "ENNO gray-300",
        "enno",
        pw_enno,
        FN_SCAN,
        Q_GRAY300,
        FT_PDF,
    )
    c.cfg(5, "ENNO sw-200", "enno", pw_enno, FN_SCAN, Q_BW200, FT_PDF)
    c.cfg(
        6,
        "ENNO color-300",
        "enno",
        pw_enno,
        FN_SCAN,
        Q_COL300,
        FT_PDF,
    )
    c.cfg(
        7,
        "ENNO color-600",
        "enno",
        pw_enno,
        FN_SCAN,
        Q_COL600,
        FT_PDF,
    )


if __name__ == "__main__":
    main()
