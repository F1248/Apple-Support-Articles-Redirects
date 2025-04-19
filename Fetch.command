#!/usr/bin/env python3.13

import itertools
import string
import time

import grequests

prefix = # Prefix, e.g. `"https://support.apple.com/en-us/HT"`
postfix = # Postfix, e.g. `"?locale=en_US"`
characters = # Allowed characters, e.g. `string.digits`
characters_1 = # Static first characters, must be in `characters`
characters_2_length = # Length of second characters
characters_3_length = # Length of third characters

characters_2_combinations = ("".join(characters) for characters in itertools.product(characters, repeat=characters_2_length))
characters_3_combinations = ["".join(characters) for characters in itertools.product(characters, repeat=characters_3_length)]

excluded_urls = [
	"https://support.apple.com/en-us/HT1598",
	"https://support.apple.com/en-us/HT1854",
	"https://support.apple.com/en-us/HT3428",
	"https://support.apple.com/en-us/HT3451",
	"https://support.apple.com/en-us/HT3452",
	"https://support.apple.com/en-us/HT3505",
	"https://support.apple.com/en-us/HT3652",
	"https://support.apple.com/en-us/HT3685",
	"https://support.apple.com/en-us/HT3687",
	"https://support.apple.com/en-us/HT4001",
	"https://support.apple.com/en-us/HT4002",
	"https://support.apple.com/en-us/HT4003",
	"https://support.apple.com/en-us/HT4074",
	"https://support.apple.com/en-us/HT4086",
	"https://support.apple.com/en-us/HT4409",
	"https://support.apple.com/en-us/HT4468",
	"https://support.apple.com/en-us/HT4595",
	"https://support.apple.com/en-us/HT4737",
	"https://support.apple.com/en-us/HT4954",
	"https://support.apple.com/en-us/HT5063",
	"https://support.apple.com/en-us/HT5066",
	"https://support.apple.com/en-us/HT5207",
	"https://support.apple.com/en-us/HT5216",
	"https://support.apple.com/en-us/HT5298",
	"https://support.apple.com/en-us/HT5305",
	"https://support.apple.com/en-us/HT5325",
	"https://support.apple.com/en-us/HT206158",
	"https://support.apple.com/en-us/TS1563",
	"https://support.apple.com/en-us/TS1753",
	"https://support.apple.com/en-us/TS1840",
	"https://support.apple.com/en-us/TS2395",
	"https://support.apple.com/en-us/TS2480",
	"https://support.apple.com/en-us/TS2544",
	"https://support.apple.com/en-us/TS2661",
	"https://support.apple.com/en-us/TS2710",
	"https://support.apple.com/en-us/TS2766",
	"https://support.apple.com/en-us/TS2813",
	"https://support.apple.com/en-us/TS2850",
	"https://support.apple.com/en-us/TS2873",
	"https://support.apple.com/en-us/TS3056",
	"https://support.apple.com/en-us/TS3066",
	"https://support.apple.com/en-us/TS3132",
	"https://support.apple.com/en-us/TS3155",
	"https://support.apple.com/en-us/TS3160",
	"https://support.apple.com/en-us/TS3185",
	"https://support.apple.com/en-us/TS3189",
	"https://support.apple.com/en-us/TS3342",
	"https://support.apple.com/en-us/TS3422",
	"https://support.apple.com/en-us/TS3562",
	"https://support.apple.com/en-us/TS3600",
	"https://support.apple.com/en-us/TS3839",
	"https://support.apple.com/en-us/TS3856",
	"https://support.apple.com/en-us/TS4012",
]

for characters_2 in characters_2_combinations:

	start_time = time.time()
	print(f"Fetching {prefix}{characters_1}{characters_2}{"X" * characters_3_length}{postfix} ...")
	succeeded = False

	while not succeeded:

		succeeded = True

		for response in grequests.map(
			(
				grequests.get(url) for url in (
					f"{prefix}{characters_1}{characters_2}{characters_3}{postfix}" for characters_3 in characters_3_combinations
				) if url not in excluded_urls
			),
			stream=True,
			size=50,
			gtimeout=10,
		):

			if response is None:
				print(f"Error after {round(time.time() - start_time, 2)} seconds: `response` is `None`, retrying...")
				succeeded = False
				break

			if response.status_code == 404:
				continue

			if response.status_code not in (200, 403):
				print(f"Error after {round(time.time() - start_time, 2)} seconds: HTTP status code is {response.status_code}, retrying...")
				succeeded = False
				break

			if len(response.history) == 0:
				print(f"{response.url} -> {response.url}")
			else:
				print(f"{response.history[0].url} -> {response.url}")

	print(f"Fetched in {round(time.time() - start_time, 2)} seconds!")

