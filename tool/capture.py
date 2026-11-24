"""Capture every OrderKing screen on an already-connected Android device."""

import argparse
import io
import json
import os
import shutil
import subprocess
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PREVIEWS = ROOT / "docs" / "screenshots"
THEMES = ("light", "dark")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", default="127.0.0.1:5555")
    args = parser.parse_args()
    flutter = shutil.which("flutter")
    android_sdk = os.environ.get("ANDROID_SDK_ROOT") or os.environ.get("ANDROID_HOME")
    if android_sdk is None and os.name == "nt":
        android_sdk = str(Path(os.environ["LOCALAPPDATA"]) / "Android" / "Sdk")
    adb = shutil.which("adb") or str(Path(android_sdk or "") / "platform-tools" / "adb")
    if not flutter:
        parser.error("Flutter must be available on PATH.")
    adb_command = [adb, "-s", args.device]
    rows = json.loads((ROOT / "docs" / "design-manifest.json").read_text(encoding="utf-8-sig"))
    names = {row["key"] for row in rows} | {"favorites"}
    expected = {f"{theme}/{name}" for theme in THEMES for name in names}

    with tempfile.TemporaryDirectory(prefix="orderking-capture-") as staging:
        output = Path(staging)
        for theme in THEMES:
            (output / theme).mkdir()

        class Receiver(BaseHTTPRequestHandler):
            def do_POST(self):
                name = self.path.removeprefix("/")
                try:
                    size = int(self.headers.get("Content-Length", "0"))
                    if name not in expected or not 0 < size <= 8_000_000:
                        self.send_error(400)
                        return
                    with Image.open(io.BytesIO(self.rfile.read(size))) as shot:
                        shot.convert("RGB").save(
                            output / f"{name}.webp", quality=92, method=4
                        )
                except (OSError, ValueError) as error:
                    self.send_error(500, str(error))
                    return
                self.send_response(204)
                self.end_headers()

            def log_message(self, format, *args):
                if not (len(args) >= 2 and args[1] == "204"):
                    super().log_message(format, *args)

        with ThreadingHTTPServer(("127.0.0.1", 0), Receiver) as receiver:
            port = receiver.server_port
            bridge = f"tcp:{port}"
            worker = threading.Thread(target=receiver.serve_forever, daemon=True)
            worker.start()
            linked = False
            try:
                subprocess.run([*adb_command, "reverse", bridge, bridge], check=True)
                linked = True
                subprocess.run(
                    [
                        flutter, "test", "integration_test/screens_test.dart",
                        "-d", args.device, f"--dart-define=ORDERKING_CAPTURE_PORT={port}",
                    ],
                    cwd=ROOT, check=True,
                )
                actual = {
                    file.relative_to(output).with_suffix("").as_posix()
                    for file in output.glob("*/*.webp")
                }
                if actual != expected:
                    raise RuntimeError(f"Missing captures: {sorted(expected - actual)}")
                shutil.copytree(output, PREVIEWS, dirs_exist_ok=True)
                print(f"Saved {len(actual)} Flutter screenshots to {PREVIEWS}")
            finally:
                if linked:
                    subprocess.run([*adb_command, "reverse", "--remove", bridge], check=False)
                receiver.shutdown()


if __name__ == "__main__":
    main()
