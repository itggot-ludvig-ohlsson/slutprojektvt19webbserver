# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning
Forum likt Reddit där man bl.a. kan skapa subs, posts, kommentarer och ha en profilsida.

## 2. Vyer (sidor)
### Alla vyer
- Lista av subs
- Navbar

### /register
- Registrering av användare

### /login
- Inloggning

### /
- Lista av posts

### /sub/:id
- Lista av posts
- Info om subben

### /post/:id
- Visa post
- Titel
- Content
- #### Info
    - Antal röster
    - Post author

### /user/:id
- User bio

### /create_post
- Skapa post

### /create_sub
- Skapa sub

### /edit_sub
- Ändra på infon om en sub

### /edit_user
- Ändra "about me" på ens profil

## 3. Funktionalitet (med sekvensdiagram)
![Post Creation Sequence Diagram](Sequence%20Diagram.png)

Utöver vad sekvensdiagramet visar finns även dessa funktioner:
- TODO

## 4. Arkitektur (Beskriv filer och mappar)
- ### db
    - Innehåller databasen 'db.db'
- ### public
    - #### css
        - Innehåller CSS för alla sidor ('styles.css')
- ### views
    - View-delen av MVC
    - Innehåller alla sidor i slim
    - 'layout.slim' bestämmer grundlayouten för varje sida
    - Resterande slim filer är för var sin sida

- 'app.rb' är Controller-delen av MVC och har koden för alla routes
- 'db.rb' är Model-delen av MVC och har koden för interaktionen med databasen

## 5. (Databas med ER-diagram)
TODO