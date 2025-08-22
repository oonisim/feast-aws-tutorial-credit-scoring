# Additional Requirement
Need dms:decrypt permission.
Need 'pip install feast[aws]'


# Breaking changes with 0.51
* [RedshiftSource.__init__() got an unexpected keyword argument 'event_timestamp_column' #7](https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/7)
* [Redshift Source - Unable to infer a name for this data source. Either table or name must be specified. #8
Open](https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/8)
* [FeatureView.__init__() got an unexpected keyword argument 'features'](https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/9)

After the fixes:
```
$ feast apply
No project found in the repository. Using project name credit_scoring_aws defined in feature_store.yaml
Applying changes for project credit_scoring_aws
Deploying infrastructure for zipcode_features
Deploying infrastructure for credit_history
```

# Unknown issue

* [KeyError: 'event_timestamp' at feast materialize-incremental #11](https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/11)

**Workaround**

```
credit_history = FeatureView(
    name="credit_history",
    # entities=["dob_ssn"],
    entities=[dob_ssn],
    # Extending TTL from 90 to 3650 (same with zipcode_features FeatureView)
    # KeyError: 'event_timestamp'
    # https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/11
    # ttl=timedelta(days=90),
    ttl=timedelta(days=3650),
    ...
```