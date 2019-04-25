# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
Reddit-ish men med infinite subreddits

## 2. Vyer (sidor)
### Frontpage
- List of subreddits
- List of posts

### Subs
- List of posts/subs
- #### About
- #### Posts
- #### Subs
  - Redirects to sub

### Accounts
- #### About

## 3. Funktionalitet (med sekvensdiagram)
## 4. Arkitektur (Beskriv filer och mappar)
- #### db
    - Innehåller databasen 'db.db'
- #### public
    - ##### css
        - Innehåller CSS för alla sidor ('styles.css')
- #### views
    - View-delen av MVC
    - Innehåller alla sidor i slim
    - 'layout.slim' bestämmer grundlayouten för varje sida
    - Resterande slim filer är för var sin sida
- 'app.rb' är Controller-delen av MVC och har koden för alla routes
- 'db.rb' är Model-delen av MVC och har koden för interaktionen med databasen

## 5. (Databas med ER-diagram)
