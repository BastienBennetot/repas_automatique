# Application R shiny de repas automatique
Cette application shiny permet de construire une liste de repas et de course automatiquement




## Comment lancer l'application shiny
Pour lancer l'application, vous avez besoin du package **shiny** dans R afin de pouvoir lancer la fonction `runGitHub()`. 
Par exemple, il suffit de lancer :

```R
if (!require('shiny')) install.packages("shiny")
shiny::runGitHub("repas_automatique", "BastienBennetot",ref="main")
```
Autrement, vous pouvez télécharger le répértoire github et utiliser la fonction `runApp()`.
