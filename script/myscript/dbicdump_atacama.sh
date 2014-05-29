dbicdump -o dump_directory=/home/atacama/Atacama/lib \
-o components='["InflateColumn::DateTime", "TimeStamp", "PassphraseColumn"]' \
-o use_moose=1 -o overwrite_modifications=1 -o preserve_case=1 \
-o moniker_map='{users_roles=> "UserRole", orders_projects=>"OrderProject"}' \
Atacama::Schema dbi:mysql:database=atacama <user> <password>
