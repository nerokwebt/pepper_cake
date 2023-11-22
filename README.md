### Informations
The app is designed to help users find meals with the ingredients they currently possess.

#### How to use:
Users are supposed to enter **every ingredient they have** to find matching meals. Meals with **ingredients the user do not possess won't be returned by the search** query.
Though, meals matching with some of these ingredients will be **displayed as suggestions**.

Examples of ingredients:
- oeuf (returns 1 meal)
- oeuf, chocolat (returns 2 meals)
- pomme de terre  (returns no meal but some suggestions)
- oeuf, chocolat, pomme de terre, reblochon, lardons, oignon, crème (returns 4 meals)

#### Additional context:
Additionally, the app uses [french-language recipes](https://pennylane-interviewing-assets-20220328.s3.eu-west-1.amazonaws.com/recipes-fr.json.gz) scraped from [www.marmiton.org](http://www.marmiton.org/) to seed the database. Ingredients from the dataset are **parsed** and **normalized**. A few aberrations remain and, given enough time, should be caught by the Normalizer (example: "pomme de teere" instead of "pomme de terre").

---

### User Stories

As a user, I want to find a meal I can cook with ingredients in my kitchen, so I don't have to think about it myself and/or spend money.

I go to the [Pepper Cake website](https://peppercake.fly.dev).

#### Cases :
1. I fill my ingredients in the search bar. I find a corresponding meal I like. I click on it and get the infos and recipe.
2. I fill my ingredients in the search bar. I don't find a corresponding meal or one that I like. I either fill more ingredients in or click on the suggested meals that contains some of the ingredients I filled.
3. I don't fill my ingredients in the search bar. I directly click on one of the suggested meals that are among the best on the website.

---

### Database structure
![database structure](https://i.ibb.co/9HBVfVr/database-structure.png)
