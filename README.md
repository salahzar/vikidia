vikidia
=======
This mod is simply defining a block named vikidia, when placed and rightclicked
it presents a form where you can look for a word in configured wikipedia-like website
it launchs the json oriented version
see https://qastack.it/programming/8555320/is-there-a-clean-wikipedia-api-just-for-retrieve-content-summary.

Form has the following fields
Exit to exit the form (or exit)
Search for searching a word with search button
when pressed the wikipedia like site is called and the extract is shown in the underlying field if present
otherwise a not present info is shown.

For instance in italian wikipedia searching for "gatto" returns
""

The https call seems leaking and not working after a while so I had to use a php proxy with the following code and pointing to that.

```php
  <?php
  $get=$_GET["name"];
  $url="https://it.vikidia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=".$_GET["name"];
  //echo($url);
  $ch = curl_init($url);

  curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

  $output = curl_exec($ch);
  curl_close($ch);
  echo($output);
  ?>
```

