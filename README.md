# Balance
This is an iOS app really only built for one user that allows you to track calories without anything else getting in the way.

It pulls resting and active energy from Apple Health and allows you to input your net calorie goal. The database of foods is only those that you have entered, and the only data you need to provide is the serving size and the number of calories. It will then show you your net calories for the day and a list of foods you ate. If you tap on the number of net calories, it will show you a rough estimate of expected weight change based on that number of calories.

## Warning
Like all calorie tracking apps, this app is not suitable for everybody, especially those with a history of eating disorders. If you think you may be at risk of an eating disorder, please seek guidance from a healthcare professional before using this app.

For more information on eating disorders or for screening, check out [NEDA's website](https://www.nationaleatingdisorders.org).

The barebones calorie tracking approach used in this apps is primarily effective for those with no concern over the nutritional balance of their diet, but who have trouble with unintentional overeating or remembering to eat enough.

## Finicky bits
One of the things I'm still working on trying to work around is that Apple Heatlh does a very inconsistent job with estimating resting energy. If you don't wear the Apple Watch, it will not estimate Resting Energy, but when you first put it on, it will estimate for recent time that it was not worn. Usually this means if you charge it overnight and wear it every day, it estimates successfully, but sometimes it just doesn't, and there are gaps.

Pay attention to any sudden changes to your BMR in the app, as you may need to go into the Apple Health app and manually add in some Resting Energy entries to fill in such a gap.

Also if you move around a lot while not wearing the watch, note that it will therefore greatly underestimate your Active Energy, which means your NEAT will be low in the app.

## Fine Details
The app breaks down energy into 4 categories:
- Exercise: This is what is referred to academically as Exercise Activity Thermogensis (EAT). This represents calories burned due to intentional exercise. The app gets this by looking at Active Energy during the duration of a tracked workout in Apple Health. I don't use the acronym because EAT sounds like dietary energy if you don't know this terminology.
- NEAT: Non-exercise Activity Thermogenesis. This represents calories burned due to background activity throughout each day. This is the Activy Energy from Apple Health, minus the Exercise category as described above.
- BMR: Base Metabolic Rate. This is the energy burned in order to keep your body functioning. For most people, this will be the majority of your calorie burn.
- Dietary: This is the total calories of the food you ate.

The total of your Exercise, NEAT, and BMR is your total calorie burn for the day, and if you subtract this from your Dietary energy, you get your net calories for the day, as shown in the big circle.

Note that if you intend to maintain your current weight, and every one of the above values are tracked perfectly, your goal should be to have zero net calories for each day, meaning you burn exactly what you consume, leaving none to be stored in fat or needing to be burned from fat. To lose weight, the value should be negative, and to gain weight the value should be positive. This may be different than previous apps you have used as they tend to obfuscate your actual net calories in favor of showing distance from a goal or something like that.

Beneath the section with your calorie breakdown is a message stating how many calories off from your goal you are and in which direction. Depending on whether you are trying to lose, gain, or maintain weight, as indicated by whether your goal is negative, positive, or zero, respectively, the message will be slightly different (e.g. "You can eat 345 more calories today," if losing weight, vs "You should eat 345 more calories today," if gaining or maintaining weight.)

Since I use the app for losing weight currently, I have only extensively tested that side of things. If you encounter bugs while using the app to gain weight or don't like the messaging, let me know via an issue, and I'm not very active responding to them, but when I see it I'll take a look at the issue.

For changes that effect my usage of the app, feel free to make a PR and I'll take a look, but don't be offended if I don't merge it in, because my main purpose in making this is for my own usage, to have something perfectly suited to my needs, so I'll only accept the change if it doesn't affect my usage or I agree. The simplicity was one of the primary goals of this app, so I'll only add new features if I want to use them or they stay fully out of the way.

That being said, feel free to fork and make whatever changes you want for your own personal use.

## Deploying and Configuring a backend
Deploying the app for your own use requires that you stand up a backend service with the following REST endpoints:
- food
- diaryEntry

See the structs Food and DiaryEntry in `Balance/Domain/API Objects` for a list of fields the database must support.

You also must provide Config.xcconfig file at the root of the project with the following fields:
- `API_BASE_URL`: The base URL for your API, e.g. if your diaryEntry endpoint is `https://foo.com/api/diaryEntry`, then your base URL would be `https://foo.com/api/`
- `API_KEY_HEADER`: The header key that is read to authenticate to your API
- `API_KEY`: The header value that is sent to authenticate to your API

If you would like to authenticate through a different method, you will need to modify the code.

