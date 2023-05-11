import dash
# import dash_core_components as dcc
from dash import dcc,html
import plotly.express as px
import pandas as pd
import pymssql
from dash.dependencies import Input,Output

database = 'pokemon'
table = 'dbo.pokemon_shirleycho'
username= 'pokemon'
password = 'Poke_Password1!'
server = 'cohort50sqlserver.database.windows.net'

app = dash.Dash(__name__)
def createFig():
    conn = pymssql.connect(server,username,password,database)
    cursor = conn.cursor()

    query = f"SELECT* FROM {table}"
    df = pd.read_sql(query,conn)

    print(df.info())

    fig = px.scatter(df,x='pokemon_weight',y='pokemon_height',title="Pokemon weight vs height")
    return fig
# df2 = df.groupby('pokemon_name').count().reset_index()

def createFig2():
    conn = pymssql.connect(server,username,password,database)
    cursor = conn.cursor()

    query = f"SELECT* FROM {table}"
    df = pd.read_sql(query,conn)
    df2 = df['pokemon_name'].value_counts()

    #print(df2)
    fig = px.bar(df2,x=df2.index,y='count',title="Pokemon weight vs height")
    return fig

app.layout = html.Div(children=[
    
    html.H1(children='Hello Dash'),
    dcc.Graph(id='someid',
              figure=createFig()),
    dcc.Graph(id='someid2',
              figure=createFig2()),
    dcc.Interval(
        id='interval-component',
        interval = 5*1000,
        n_intervals=0
    ),
    html.H1(children="More graphs?"),
    dcc.Graph(id='someid3',
              figure=createFig()),
    
])

@app.callback(Output('someid2','figure'),
              Input('interval-component','n_intervals'))
def UpdateData(n):
    conn = pymssql.connect(server,username,password,database)
    cursor = conn.cursor()

    query = f"SELECT* FROM {table}"
    df = pd.read_sql(query,conn)
    df2 = df['pokemon_name'].value_counts()

    #print(df2)
    fig = px.bar(df2,x=df2.index,y='count',title="Pokemon weight vs height")
    return fig
    
@app.callback(Output('someid','figure'),
              Input('interval-component','n_intervals'))
def UpdateData1(n):
    conn = pymssql.connect(server,username,password,database)
    cursor = conn.cursor()

    query = f"SELECT* FROM {table}"
    df = pd.read_sql(query,conn)

    print(df.info())

    fig = px.scatter(df,x='pokemon_weight',y='pokemon_height',title="Pokemon weight vs height")
    return fig


if __name__=='__main__':
    app.run_server(debug=True,host='0.0.0.0',port = '80')