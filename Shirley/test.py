import pandas as pd 

df = pd.read_csv(r"./Shirley/Data/itineraries.csv", low_memory=False)
print(df.head())
