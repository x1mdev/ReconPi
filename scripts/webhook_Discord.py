import sys
import os
from discord import Webhook, RequestsWebhookAdapter

webhook_url = os.environ['DISCORD_WEBHOOK_URL']
pathlist = webhook_url.split("/")
webhook_id = pathlist[5]
webhook_token = pathlist[6]

if webhook_id and webhook_token and webhook_id != "xxx" and webhook_token != "xxx":

    message = sys.stdin.readlines()

    delimiter = "\n"

    # Create webhook
    webhook = Webhook.partial(webhook_id, webhook_token,\
            adapter=RequestsWebhookAdapter())

    # Content to send to discord (max 2000 characters)
    content = ""

    # Split message at \\n character 
    for line in message[0].split("\\n"):
        # Append newline, so discord does a line break.
        formatted_line =  [element+delimiter for element in line.split(delimiter) if element]
        if formatted_line:
            if len(content + formatted_line[0]) > 2000:
                # Send content to discord
                webhook.send(content)
                # Reset content to send
                content = ""
            else:
                # Add current formatted line to the content
                content += formatted_line[0]

    # Check if there is some unsend content
    if content:
        webhook.send(content)
