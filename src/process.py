import pandas as pd

data = pd.read_csv("input/Sentiment.csv")
data.columns = [col.replace(":", "_") for col in data.columns]
data.insert(0, "id", list(range(1, len(data)+1)))

conversion = {
    "object": "TEXT",
    "float64": "NUMERIC",
    "int64": "INTEGER"
}

sql = """.separator ","

CREATE TABLE Sentiment (
%s);

.import "working/noHeader/Sentiment.csv" Sentiment
""" % ",\n".join(["    %s %s%s" % (key,
                                   conversion[str(data.dtypes[key])],
                                   " PRIMARY KEY" if key=="id" else "")
                  for key in data.dtypes.keys()])

data.to_csv("output/Sentiment.csv", index=False)

open("working/import.sql", "w").write(sql)
