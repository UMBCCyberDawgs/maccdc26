import time
import statistics
from collections import defaultdict, deque
from scapy.all import sniff, UDP, IP

# ===================== CONFIGURATION =====================
WINDOW_SIZE = 40          # Number of packets per flow window
MIN_PACKETS = 20          # Minimum packets before analysis
MAX_TIME_STD = 0.25       # Seconds (low variance = beaconing)
MAX_SIZE_STD = 12         # Bytes
ALERT_COOLDOWN = 60       # Seconds between alerts per flow
# =========================================================

flows = defaultdict(lambda: {
    "timestamps": deque(maxlen=WINDOW_SIZE),
    "sizes": deque(maxlen=WINDOW_SIZE),
    "last_alert": 0
})

def is_beaconing(flow):
    times = flow["timestamps"]
    sizes = flow["sizes"]

    if len(times) < MIN_PACKETS:
        return False

    intervals = [
        times[i + 1] - times[i]
        for i in range(len(times) - 1)
    ]

    if len(intervals) < 2:
        return False

    time_std = statistics.pstdev(intervals)
    size_std = statistics.pstdev(sizes)

    return time_std < MAX_TIME_STD and size_std < MAX_SIZE_STD

def alert(flow_key, flow):
    now = time.time()
    if now - flow["last_alert"] < ALERT_COOLDOWN:
        return

    intervals = [
        flow["timestamps"][i + 1] - flow["timestamps"][i]
        for i in range(len(flow["timestamps"]) - 1)
    ]

    print("\n UDP BEACONING SUSPECTED")
    print(f"Flow       : {flow_key[0]}:{flow_key[1]} → {flow_key[2]}:{flow_key[3]}")
    print(f"Packets    : {len(flow['timestamps'])}")
    print(f"Avg period : {sum(intervals)/len(intervals):.3f}s")
    print(f"Time STD   : {statistics.pstdev(intervals):.4f}")
    print(f"Size STD   : {statistics.pstdev(flow['sizes']):.2f}")
    print("--------------------------------------------------")

    flow["last_alert"] = now

def packet_handler(pkt):
    if not pkt.haslayer(UDP) or not pkt.haslayer(IP):
        return

    ip = pkt[IP]
    udp = pkt[UDP]

    flow_key = (ip.src, udp.sport, ip.dst, udp.dport)
    flow = flows[flow_key]

    flow["timestamps"].append(time.time())
    flow["sizes"].append(len(pkt))

    if is_beaconing(flow):
        alert(flow_key, flow)

def main():
    print("UDP Beaconing Malware Detector")
    print("Listening for suspicious UDP traffic...\n")
    sniff(filter="udp", prn=packet_handler, store=False)
    print("No beaconing found")

if __name__ == "__main__":
    main()
