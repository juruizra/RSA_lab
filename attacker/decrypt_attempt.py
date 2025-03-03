from scapy.all import rdpcap
from Crypto.PublicKey import RSA
from sympy import factorint
from math import gcd
import sys

def extract_payload(pcap_file):
    # Read the pcap file
    packets = rdpcap(pcap_file)
    
    # Extract payload from TCP packets (adjust filter as needed)
    payload = b""
    for packet in packets:
        if packet.haslayer("TCP"):
            payload += bytes(packet["TCP"].payload)
    
    if not payload:
        raise ValueError("No payload found in pcap file")
    
    return payload

def crack_rsa(n, e):
    # Factor n into p and q
    factors = factorint(n)
    if len(factors) != 2:
        raise ValueError("n must be a product of two primes")
    p, q = factors.keys()
    
    # Compute phi(n)
    phi = (p - 1) * (q - 1)
    
    # Compute modular inverse of e mod phi(n) (private key d)
    d = pow(e, -1, phi)
    return d, p, q

def decrypt_payload(ciphertext, d, n):
    # Decrypt using RSA
    plaintext = pow(int.from_bytes(ciphertext, "big"), d, n)
    return plaintext.to_bytes((plaintext.bit_length() + 7) // 8, "big").decode()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <pcap_file> <public_key_file>")
        sys.exit(1)
    
    pcap_file = sys.argv[1]
    public_key_file = sys.argv[2]
    
    try:
        # Step 1: Extract payload from pcap
        ciphertext = extract_payload(pcap_file)
        print(f"[+] Extracted ciphertext: {ciphertext.hex()}")
        
        # Step 2: Extract n and e from public key
        with open(public_key_file, "rb") as f:
            public_key = RSA.import_key(f.read())
        n = public_key.n
        e = public_key.e
        print(f"[+] Extracted public key: n={n}, e={e}")
        
        # Step 3: Crack RSA to get private key d
        d, p, q = crack_rsa(n, e)
        print(f"[+] Cracked private key: d={d}, p={p}, q={q}")
        
        # Step 4: Decrypt payload
        plaintext = decrypt_payload(ciphertext, d, n)
        print(f"[+] Decrypted plaintext: {plaintext}")
    
    except Exception as err:
        print(f"[-] Error: {err}")