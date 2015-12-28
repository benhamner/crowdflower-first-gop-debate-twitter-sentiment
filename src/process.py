import pandas as pd

data = pd.read_csv("input/Sentiment.csv")

data.columns = [col.replace(":", "_") for col in data.columns]

conversion = {
    "object": "TEXT",
    "float64": "NUMERIC",
    "int64": "INTEGER"
}

sql = """.separator ","

CREATE TABLE Sentiment (
%s);

.import "working/noHeader/Sentiment.csv" Sentiment
""" % ",\n".join(["    %s %s" % (key, conversion[str(data.dtypes[key])]) for key in data.dtypes.keys()])

data.to_csv("output/Sentiment.csv", index=False)

open("working/import.sql", "w").write(sql)
