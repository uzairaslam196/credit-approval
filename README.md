# CreditApproval

This straightforward Phoenix application employs live views on the front end. Therefore, no additional setup is required.
To store user information and show the results to user, it makes advantage of the live view state. As a result, we can currently launch the application without any database setup. Later, we'll also build a database for it.
The state (data) is discarded when the page is refreshed since the live view process is restarted with the default state. You can restart the entire flow at any moment without refreshing the page, though. Huraaaa!! This is therefore incredibly intriguing and easy to utilise.

Requirements:
  * Elixir 1.12.2
  * Erlang 24.0.6
 
Once Elixir setup is completed, then go into the project and perform following steps:
  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

  Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


Once it get started, we can see this screen:
![Alt text](priv/static/images/home_screen_ss.png?raw=true "Home Screen")

Click on start button to fill only name & email field:
![Alt text](priv/static/images/user_screen_ss.png?raw=true "User Information")

Click on Submit and questions start to appear one by one on screen:
![Alt text](priv/static/images/questioning_ss.png?raw=true "Questions")

User can go navigate back to previous question easily to answer the question again.

In last, expected result show on home screen.

Further Details About Files:

- live view files path `lib/credit_approval_web/live`
- home screen `lib/credit_approval_web/live/calculate/index`
- component for questioning `lib/credit_approval_web/live/calculate/question_component`
- embedded schema for user `lib/credit_approval_web/live/calculate/user`
- embedded schema for user answers `lib/credit_approval_web/live/calculate/user_answers`
- questions are list of maps, currently it's hard written in file because application doesn't has db yet `lib/credit_approval/questions_data.ex`
- Request to get scoreCredits against points in `lib/credit_approval/approval_client.ex`

Although the application does not yet support databases, but its structure of entities can be readily copied to create migrations.
So let's go through each entity to understand the structure. The current structure was created with the idea that the application owner might add more questions and change them. Owner would have also change the types of answers for existing ones, such as strings, booleans, and integers, in the future.
It has a question entity with both a description and the type of answer. The field `answer type: float` in the object of a question is present if the expected answer is a float value. Each question must be displayed at the appropriate stage where it occurs. To ensure the sequence of the questions on the form, an index key is also present.

Second entity represent the `User` and third entity is for `User Answers` which will hold question_id, user_id and answer with its value type.

Currently they are just embedded schemas which can fulfill the application current requirements. 

Later on, we are thinkning to add
- another new table which holds calculation related information. 
- another new table which holds question types e.g income, expense
- currencies

(By building these tables, owner can set calculations for different answers at runtime. We will be able to use many features for example `expense` related answer should be subtract/add from `income`)).
