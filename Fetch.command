#!/usr/bin/env python3.13

import itertools
import string
import time

import grequests

prefix = # Prefix, e.g. `"https://support.apple.com/en-us/HT"`
characters = # Allowed characters, e.g. `string.digits`
characters_1 = # Static first characters, must be in `characters`
characters_2_length = # Length of second characters
characters_3_length = # Length of third characters

characters_2_combinations = ("".join(characters) for characters in itertools.product(characters, repeat=characters_2_length))
characters_3_combinations = ["".join(characters) for characters in itertools.product(characters, repeat=characters_3_length)]

excluded_urls = [
	"https://support.apple.com/en-us/HT206158"
]

for characters_2 in characters_2_combinations:

	start_time = time.time()
	print(f"Fetching {prefix}{characters_1}{characters_2}{"X" * characters_3_length} ...")
	succeeded = False

	while not succeeded:

		succeeded = True

		for response in grequests.map(
			(
				grequests.get(url) for url in (
					url for url in (
						f"{prefix}{characters_1}{characters_2}{characters_3}" for characters_3 in characters_3_combinations
					) if url not in excluded_urls
				)
			),
			stream=True,
			size=50,
			gtimeout=10
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
				print(f"\"{response.url}\" -> \"{response.url}\"")
			else:
				print(f"\"{response.history[0].url}\" -> \"{response.url}\"")

	print(f"Fetched in {round(time.time() - start_time, 2)} seconds!")

