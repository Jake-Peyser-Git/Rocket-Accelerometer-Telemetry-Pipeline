import socket
import time
import numpy as np

UDP_IP = "0.0.0.0"
UDP_PORT = 4444

CALIB_TIME_SEC = 5.0

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((UDP_IP, UDP_PORT))

    print("Calibration: keep sensor stationary")

    samples = []
    start = time.time()

    # -------- collect calibration data --------
    while time.time() - start < CALIB_TIME_SEC:
        data, _ = sock.recvfrom(1024)

        try:
            line = data.decode().strip()
            parts = line.split(",")

            if len(parts) != 4:
                continue

            _, ax, ay, az = parts
            samples.append([float(ax), float(ay), float(az)])

        except:
            continue

    sock.close()

    if len(samples) == 0:
        print("No data received.")
        return

    samples = np.array(samples)

    # -------- compute bias (gravity included) --------
    bias = np.mean(samples, axis=0)

    print("\nCalibration complete")
    print("Bias vector (ax, ay, az):")
    print(f"{bias[0]:.6f}, {bias[1]:.6f}, {bias[2]:.6f}")

    print("\nProgram terminated.")

if __name__ == "__main__":
    main()