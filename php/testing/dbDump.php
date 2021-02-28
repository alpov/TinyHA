<?php

header("Content-Type: text/plain");

$db = new PDO("sqlite:/opt/tinyha/db/tinyha.db");
$query = $db->query("select * from tank where dt > datetime('now', '-1 day') order by id asc");
$first_row = true;
while ($row = $query->fetch(PDO::FETCH_ASSOC))
{
  if ($first_row)
  {
    // I'm not sure how to get the field names using a PDO method but
    // we can use the first row's (or any row's) key values as these
    // are the field names.
    $first_row = false;
    $number_of_fields = count($row);
    $field_names = array_keys($row);
    $first_field_name = $field_names[0];
  }
  // do stuff here with the row
  echo implode(';', $row) . "\r\n";
}

?>
