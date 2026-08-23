import socket
import csv
import os
from datetime import datetime

UDP_IP = "0.0.0.0"
UDP_PORT = 4444

CSV_PATH = r"C:\Users\jacob\data\accelerometer_data.csv"

def main():
    print("Writing CSV to:", CSV_PATH)

    # Allow socket reuse (prevents WinError 10048 on restart)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    sock.bind((UDP_IP, UDP_PORT))

    # Ensure folder exists
    os.makedirs(os.path.dirname(CSV_PATH), exist_ok=True)

    with open(CSV_PATH, "w", newline="") as f:
        writer = csv.writer(f)

        # CSV header
        writer.writerow(["pc_time", "pico_us", "ax", "ay", "az"])
        f.flush()
        os.fsync(f.fileno())

        print(f"Listening on UDP {UDP_IP}:{UDP_PORT}\n")

        while True:
            data, addr = sock.recvfrom(1024)

            try:
                text = data.decode("utf-8").strip()
            except UnicodeDecodeError:
                print("BAD PACKET (non-utf8):", data)
                continue

            # handle possible multiple lines per UDP packet
            for line in text.split("\n"):
                parts = line.split(",")

                if len(parts) != 4:
                    print("SKIP:", repr(line))
                    continue

                pico_us, ax, ay, az = parts

                pc_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

                row = [pc_time, pico_us, ax, ay, az]

                print(row)

                writer.writerow(row)

                # force write to disk immediately
                f.flush()
                os.fsync(f.fileno())


if __name__ == "__main__":
    main()