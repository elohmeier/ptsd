#!/usr/bin/env python3

import argparse
import hashlib

from sqlalchemy import create_engine
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session


def main():
    parser = argparse.ArgumentParser(description="Check if a file is in paperless")
    parser.add_argument(
        "file", help="The file to check", type=argparse.FileType("rb"), nargs="+"
    )
    args = parser.parse_args()

    Base = automap_base()
    engine = create_engine("sqlite:////Users/enno/.local/share/paperless/db.sqlite3")
    Base.prepare(autoload_with=engine)
    Document = Base.classes.documents_document
    Comment = Base.classes.documents_comment
    session = Session(engine)

    for f in args.file:
        md5 = hashlib.md5(f.read()).hexdigest()
        docs = session.query(Document).filter(Document.checksum == md5).all()
        if len(docs) > 0:
            print(f.name, "is in paperless")
            for doc in docs:
                print("  ", doc.title)
        else:
            print(f.name, "is not in paperless")


if __name__ == "__main__":
    main()
