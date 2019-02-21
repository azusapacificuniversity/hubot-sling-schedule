# hubot-sling-schedule

Allows hubot to pull shift information from Sling and display who is currently working.

See src/slingbot.coffee for full documentation.

### Installation
In hubot project repo, run:
`npm install hubot-sling-schedule --save` 

Then add **hubot-sling-schedule** to your `external-scripts.json`:
```["hubot-sling-schedule"]```



### Configuration:
```
SLING_AUTH_TOKEN - (required) authorization token for the Sling API (more info: https://api.sling.is/)
```

### Commands:
```
hubot who's here - returns names of employees who are currently on shift along with their shift start/end times and shift summaries
```

### Running hubot-sling-schedule Locally

You can test your hubot by running the following, however some plugins will not
behave as expected unless the [environment variables](#configuration) they rely
upon have been set.

You can start hubot-sling-schedule locally by running:

    % bin/hubot

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    hubot-sling-schedule>

Then you can interact with hubot-sling-schedule by typing `hubot-sling-schedule help`.

    hubot-sling-schedule> hubot-sling-schedule help
    hubot-sling-schedule animate me <query> - The same thing as `image me`, except adds [snip]
    hubot-sling-schedule help - Displays all of the help commands that hubot-sling-schedule knows about.
    ...

