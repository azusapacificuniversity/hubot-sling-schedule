module.exports = (robot) ->

    robot.hear /who here/i, (res) ->
        # get all user data from sling
        
        robot.http("https://api.sling.is/v1/users")
            .headers('Accept': 'application/json', 'Authorization': auth)
            .get() (err, response, body) ->
                if err 
                    console.log(err)
                    return
                
                user_list = JSON.parse body   # returns a list of dictionaries
                console.log(user_list[0].name)

                now = new Date
                console.log("right now: " + now)
                
                now_formatted = now.toISOString()
                now_formatted = now_formatted.replace(/:/g, '%3A')
                
                robot.http("https://api.sling.is/v1/reports/timesheets?dates=#{now_formatted}")
                    .headers('Accept': 'application/json', 'Authorization': auth)
                    .get() (err, response, body) ->
                        if err 
                            console.log('something went wrong!!')
                            console.log(err)
                            return
                        
                        todays_shifts = JSON.parse body

                        current_shifts = []
                        for shift in todays_shifts
                            start_time = new Date(shift.dtstart)
                            end_time = new Date(shift.dtend)
                            # if the shift is happening right now
                            if now >= start_time && now < end_time
                                current_shifts.push(shift)
                        console.log(current_shifts.length)

                        for shift in current_shifts
                            # filters through all users json and finds the shift owner details via user_id
                            shift_owner = user_list.filter( (user) -> 
                                return user.id == shift.user.id  
                            )
                            # the filtering above returns a list, this is for formatting sake
                            shift_owner = shift_owner[0]

                            console.log(shift_owner.name)
                            
                            
