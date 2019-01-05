<h1>Bienvenue sur Awesome Barnaby App API!</h1>

Cette API permet de chercher des bars, ou autres établissements, avec de simples queries texte. Elle nous renvoie au plus 15 bars de l'API Google Places et retourne les bars de la base de données qui correspondent à la recherche par nom ou bien les plus proches des résultats donnés par Google. Une recherche sur notre API nous renvoie une liste des bars/établissements avec des informations sur chaque endroit comme addresse, coordonnées géographiques, type, note sur cinq et plus. Le résultat de la requête HTTP sur notre API est sous forme de JSON.

Notre API a plusieurs endpoints et plusieurs fonctionnalités qui permettent à l'utilisateur de chercher n'importe quel bar, restaurant, ou autre par nom, adresse, quartier, lieux-dits, arrondissements ou ville. Il y a des paramètres requis et des paramètres optionnels.

<h3>Recherche Base de Données 💻</h3>

Tout d'abord, parlons du premier endpoint qui nous permet de trouver tous les bars de la base de données, sans accéder encore à l'API de Google Places.
- https://awesome-barnaby-app.herokuapp.com/api/v1/places
Cette requête vers l'API nous renvoie seulement les bars qui sont dans la base de données et ne requiert pas d'authentification avec une clé API.

<h3>Recherche Google Places API et Base de Données 🌍</h3>

Cet endpoint est le plus important de l'API, il permet de rechercher dans l'API Places ainsi que dans la base de données. L'API retournera tous les résultats qui matchent sur Google dans un premier temps et de la base de données dans un second. Pour les résultats de la base de données, ils seront matchés par nom et/ou par proximité (s'il y en a) avec les résultats retournés par l'API Places. Ainsi, en tapant "75015 Paris" vous aurez les 15 bars trouvés par Google, puis les bars les plus proches, aux alentours, extraits de la base de données!
- https://awesome-barnaby-app.herokuapp.com/api/v1/places/search

<strong>Paramètres requis:</strong>
- clé: votre clé API fournie afin de pouvoir vous identifier et utiliser l'application.
- q: le texte de recherche, cela peut être un nom, une adresse, un quartier, une ville, un arrondissement etc.

<strong>Paramètres optionnels:</strong>
- type: par défaut, l'API utilise le type "bar" et recherche spécifiquement des bars, mais il est possible pour vous de changer cela avec le paramètre "type". Il existe beaucoup de différents types possibles comme "restaurant", "night_club", "gym" etc.

<strong>Exemples de queries à essayer: "75015 Paris", "Orangerie", "Rue Chabanais", "Colorova", "kube bar"</strong>


<h3>La fonctionnalité bonus: DISCOVER ⭐</h3>

L'API permet aussi de découvrir de nouveaux endroits où sortir, grace à la fonctionnalité discover. Tapez le keyword "discover" dans la query et un nouveau bar au hasard vous sera retourné. Comme auparavant, l'API vous renvoie également les bars les plus proches de ce nouveau bar qui sont dans la base de données existante, s'il y en a à proximité.

<strong>Paramètres requis:</strong>
- clé: votre clé API fournie afin de pouvoir vous identifier et utiliser l'application.
- q: le texte de recherche, ici ce sera "discover", tout simplement.
