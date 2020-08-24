import sys
import requests
from ipaddress import ip_network, ip_address

def output_valid_ips(ips):
    ipvs4 = "https://www.cloudflare.com/ips-v4"
    ipvs6 = "https://www.cloudflare.com/ips-v6"

    ipranges = requests.get(ipvs4).text.split("\n")[:-1]  # removing last trailing space
    ipranges += requests.get(ipvs6).text.split("\n")[
        :-1
    ]  # removing last trailing space
    nets = []
    for iprange in ipranges:
        nets.append(ip_network(iprange))
    valid_ips = []
    for ip in ips:
        if ip == "":  # skip empty line
            continue
        valid = True
        for net in nets:
            if ip_address(ip) in net:
                valid = False
                break
        if valid:
            valid_ips.append(ip)
    return valid_ips


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(
            """
      Usage : python {} input_file_path output_file_path
      """.format(
                __file__
            )
        )
        sys.exit(1)
    file_name, output_file = sys.argv[1], sys.argv[2]

    with open(file_name) as f:
        ips = f.read().split("\n")
    valid_ips = output_valid_ips(ips)

    with open(output_file, "w") as f:
        for ip in valid_ips[:-1]:
            f.write(ip + "\n")
        # no new line after last line
        f.write(valid_ips[-1])
