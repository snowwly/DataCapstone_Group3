import pandas as pd 

df = pd.read_csv(r"./Shirley/Data/NYPD_Complaint_Data_Historic.csv", low_memory=False)
print(df.head())
print("hi")