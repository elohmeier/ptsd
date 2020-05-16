import click
import logging
import re
import requests

from io import BytesIO
from PIL import Image
from pathlib import Path
from requests.exceptions import ConnectionError

DEFAULT_TIMEOUT = 3

logger = logging.getLogger(__name__)


def fetch_set(url: str, name: str, output_directory: Path):
    subidx = requests.get(url, timeout=DEFAULT_TIMEOUT)
    if subidx.status_code != 200:
        raise Exception("failed to fetch sub-index from %s" % url)

    images = []

    for jpg_href in sorted(
        re.findall(r'<a href="(.*\.jpg)">.*</a>', subidx.text, re.MULTILINE),
        key=lambda x: int(re.split(r"(\d+)", x)[1]),
    ):
        img_url = url + jpg_href
        img_res = requests.get(img_url, timeout=DEFAULT_TIMEOUT)

        if img_res.status_code != 200:
            raise Exception("failed to fetch image from %s" % img_url)

        bio = BytesIO(img_res.content)
        try:
            images.append(Image.open(bio))
        except Exception as ex:
            raise Exception("failed to load image %s" % img_url) from ex

    pdf_path = output_directory / f"{name.rstrip()}.pdf"

    if pdf_path.exists() and not click.confirm(
        f"PDF File {pdf_path} exists, overwrite it?"
    ):
        logger.info(f"PDF {pdf_path} skipped.")
        return

    images[0].save(
        pdf_path, "PDF", resolution=100.0, save_all=True, append_images=images[1:]
    )
    logger.info("PDF saved to %s", pdf_path)


@click.command(
    help="fetch JPG groups from TinyScanner iOS App and merge them into PDF files"
)
@click.option(
    "--output-directory",
    help="Output directory to save the PDF files to",
    type=click.Path(exists=True, dir_okay=True, file_okay=False),
    required=True,
)
@click.option("--debug", type=click.BOOL)
@click.argument("ip")
def fetch_tinyscans(output_directory: str, debug: bool, ip: str):
    logging.basicConfig(
        format="%(levelname)s: %(message)s",
        level=logging.DEBUG if debug else logging.INFO,
    )

    try:
        root = f"http://{ip}:10000/"
        idx = requests.get(root, timeout=DEFAULT_TIMEOUT)

        if idx.status_code != 200:
            raise Exception("failed to fetch index from %s" % root)

        for href, name in re.findall(
            r'<a href="(.*)">(.*)/</a>', idx.text, re.MULTILINE
        ):
            if href == "..":
                continue

            logger.debug("fetching %s from %s", name, root + href)
            fetch_set(root + href, name, Path(output_directory))
    except ConnectionError:
        logger.error(
            "connection to TinyScanner app failed. Please make sure the device screen is on and the app is in the foreground."
        )


if __name__ == "__main__":
    fetch_tinyscans()
