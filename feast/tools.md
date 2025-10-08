```commandline
psql -h ${RDS_HOST_URL} -p 54320 -U pgadmin -d feast
```
```
feast=> \dt
                 List of relations
 Schema |          Name           | Type  |  Owner  
--------+-------------------------+-------+---------
 public | data_sources            | table | pgadmin
 public | entities                | table | pgadmin
 public | feast_metadata          | table | pgadmin
 public | feature_services        | table | pgadmin
 public | feature_views           | table | pgadmin
 public | managed_infra           | table | pgadmin
 public | on_demand_feature_views | table | pgadmin
 public | permissions             | table | pgadmin
 public | projects                | table | pgadmin
 public | saved_datasets          | table | pgadmin
 public | stream_feature_views    | table | pgadmin
 public | validation_references   | table | pgadmin
```


