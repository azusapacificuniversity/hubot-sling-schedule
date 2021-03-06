# Description:
#     Allows hubot to query Sling and display who is currently working along with shift times and summaries
# 
# Notes:
#     This script interacts with the Sling REST API, which can be found here: https://api.sling.is/
#     In order to interact with the API you need to have an authorization token and set it as an 
#     environmental variable on the machine running hubot.
# 
# Configuration:
#     SLING_AUTH_TOKEN - (required)
#     
# Commands:
#     hubot who's here - returns list of employees who are currently working with shift times and summary

SLING_AUTH_TOKEN = process.env.SLING_AUTH_TOKEN or false

module.exports = (robot) ->

    robot.respond /(who[']s here)/i, (res) ->        

        if SLING_AUTH_TOKEN == false
            res.reply "Oops! Looks like you haven't set a Sling authentication token as an enviromental variable \n" +
                       "More info on how to get an authentication token can be found here: https://api.sling.is/"
            return

        output = "The following are currently on shift: \n\n"
        
        # get all user data from sling
        robot.http("https://api.sling.is/v1/users")
            .headers('Accept': 'application/json', 'Authorization': SLING_AUTH_TOKEN)
            .get() (err, response, body) ->
                if err 
                    console.log('Sling API users query failed: ')
                    console.log(err)
                    return
                
                user_list = JSON.parse body
                
                now = new Date

                # adds leading 0 to JS date details (for ISO formatting)
                pad = (n) ->
                    if n < 10 then return '0' + n else return n

                now_month = pad(now.getMonth() + 1)                
                now_date = pad(now.getDate())
                now_ISOformat = now.getFullYear() + '-' + now_month + '-' + now_date

                # get all the shifts happening today
                robot.http("https://api.sling.is/v1/reports/timesheets?dates=#{now_ISOformat}")
                    .headers('Accept': 'application/json', 'Authorization': SLING_AUTH_TOKEN)
                    .get() (err, response, body) ->
                        if err 
                            console.log('Sling API timesheet query failed: ')
                            console.log(err)
                            return
                        
                        if body.includes("Feature available only in Sling Premium")
                            output = "Whoops! This feature is only available in Sling Premium"

                        todays_shifts = JSON.parse body
                        
                        current_shifts = []
                        for shift in todays_shifts
                            # format strings to objects for easier comparisons
                            start_comparison = new Date(shift.dtstart)
                            end_comparison = new Date(shift.dtend)

                            # if the shift is happening right now
                            if now >= start_comparison && now < end_comparison
                                current_shifts.push(shift)
                        
                        for shift in current_shifts
                            # filters through list of users and finds the shift owner details via user_id
                            # func filter() returns a list with 1 element, so we grab the first element "[0]"
                            shift_owner = user_list.filter( (user) -> 
                                return user.id == shift.user.id  
                            )[0]      

                            # adds full name and summary (aka location of shift)
                            summary = shift_owner.name.toString()  + " " + shift_owner.lastname.toString() + ": " + shift.summary.toString() + "\n"

                            # make timestamp easier to read with AM/PM formatting
                            options = {
                                hour: 'numeric',
                                minute: 'numeric',
                                hour12: true }
                            
                            # more date formatting to make it readable to the user bc javascript is weird
                            s = shift.dtstart.split(/\D/)
                            start_formatted = new Date(Date.UTC(+s[0], --s[1], +s[2], +s[3], +s[4], +s[5], 0))
                            start_formatted = start_formatted.toLocaleString('en-US', options).toString()

                            e = shift.dtend.split(/\D/)
                            end_formatted = new Date(Date.UTC(+e[0], --e[1], +e[2], +e[3], +e[4], +e[5], 0))
                            end_formatted = end_formatted.toLocaleString('en-US', options).toString()

                            summary += start_formatted + " – " + end_formatted + "\n\n"
                            output += summary

                        res.reply output
