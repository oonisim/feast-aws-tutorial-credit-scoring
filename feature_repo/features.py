from datetime import timedelta
from feast import (
    Entity,
    FeatureView,
    Field,
    RedshiftSource,
)
from feast.value_type import (
    ValueType
)
from feast.types import (
    String,
    Int64
)

zipcode = Entity(name="zipcode", value_type=ValueType.INT64)

zipcode_source = RedshiftSource(
    # API changed
    # Unable to infer a name for this data source. Either table or name must be specified
    # https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/8
    name="zipcode_features",
    database="dev",
    query="SELECT * FROM spectrum.zipcode_features",
    # API changed
    # RedshiftSource.__init__() got an unexpected keyword argument 'event_timestamp_column'
    # event_timestamp_column="event_timestamp",
    timestamp_field="event_timestamp",
    created_timestamp_column="created_timestamp",
)

zipcode_features = FeatureView(
    name="zipcode_features",
    # entities=["zipcode"],
    entities=[zipcode],
    ttl=timedelta(days=3650),
    # features=[
        #Feature(name="city", dtype=ValueType.STRING),
        #Feature(name="state", dtype=ValueType.STRING),
        #Feature(name="location_type", dtype=ValueType.STRING),
        #Feature(name="tax_returns_filed", dtype=ValueType.INT64),
        #Feature(name="population", dtype=ValueType.INT64),
        #Feature(name="total_wages", dtype=ValueType.INT64),
    # ],
    schema=[
        Field(name="city", dtype=String),
        Field(name="state", dtype=String),
        Field(name="location_type", dtype=String),
        Field(name="tax_returns_filed", dtype=Int64),
        Field(name="population", dtype=Int64),
        Field(name="total_wages", dtype=Int64),
    ],
    # API Change
    # FeatureView.__init__() got an unexpected keyword argument 'batch_source'
    #batch_source=zipcode_source,
    source=zipcode_source,
)

dob_ssn = Entity(
    name="dob_ssn",
    value_type=ValueType.STRING,
    description="Date of birth and last four digits of social security number",
)

credit_history_source = RedshiftSource(
    # API changed
    # Unable to infer a name for this data source. Either table or name must be specified
    # https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/8
    name="credit_history",
    database="dev",
    query="SELECT * FROM spectrum.credit_history",
    # API changed
    # RedshiftSource.__init__() got an unexpected keyword argument 'event_timestamp_column'
    # event_timestamp_column="event_timestamp",
    timestamp_field="event_timestamp",
    created_timestamp_column="created_timestamp",
)

credit_history = FeatureView(
    name="credit_history",
    # entities=["dob_ssn"],
    entities=[dob_ssn],
    # Extending TTL from 90 to 3650 (same with zipcode_features FeatureView)
    # KeyError: 'event_timestamp'
    # https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/11
    # ttl=timedelta(days=90),
    ttl=timedelta(days=3650),
    # API Change
    # FeatureView.__init__() got an unexpected keyword argument 'features'
    # https://github.com/feast-dev/feast-aws-credit-scoring-tutorial/issues/9
    #features=[
        #Feature(name="credit_card_due", dtype=ValueType.INT64),
        #Feature(name="mortgage_due", dtype=ValueType.INT64),
        #Feature(name="student_loan_due", dtype=ValueType.INT64),
        #Feature(name="vehicle_loan_due", dtype=ValueType.INT64),
        #Feature(name="hard_pulls", dtype=ValueType.INT64),
        #Feature(name="missed_payments_2y", dtype=ValueType.INT64),
        #Feature(name="missed_payments_1y", dtype=ValueType.INT64),
        #Feature(name="missed_payments_6m", dtype=ValueType.INT64),
        #Feature(name="bankruptcies", dtype=ValueType.INT64),
    #],
    schema=[
        Field(name="credit_card_due", dtype=Int64),
        Field(name="mortgage_due", dtype=Int64),
        Field(name="student_loan_due", dtype=Int64),
        Field(name="vehicle_loan_due", dtype=Int64),
        Field(name="hard_pulls", dtype=Int64),
        Field(name="missed_payments_2y", dtype=Int64),
        Field(name="missed_payments_1y", dtype=Int64),
        Field(name="missed_payments_6m", dtype=Int64),
        Field(name="bankruptcies", dtype=Int64),
    ],
    # API Change
    # FeatureView.__init__() got an unexpected keyword argument 'batch_source'
    # batch_source=credit_history_source,
    source=credit_history_source
)
