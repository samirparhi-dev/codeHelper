# snowflake_pipeline.py

import snowflake.connector
import pandas as pd
import numpy as np

# Step 1: Establish connection to Snowflake
def connect_to_snowflake():
    conn = snowflake.connector.connect(
        user=os.getenv('SNOWFLAKE_USER'),
        password=os.getenv('SNOWFLAKE_PASSWORD'),
        account=os.getenv('SNOWFLAKE_ACCOUNT')
    )
    return conn

# Step 2: Extract sales data from Snowflake
def extract_data(conn):
    query = """
    SELECT region, sales_amount, sales_date
    FROM sales_data
    WHERE sales_date >= '2024-01-01'
    """
    cur = conn.cursor()
    cur.execute(query)
    data = cur.fetchall()
    cur.close()
    return data

# Step 3: Load the data into a Pandas DataFrame
def load_data_to_dataframe(data):
    columns = ['region', 'sales_amount', 'sales_date']
    df = pd.DataFrame(data, columns=columns)
    return df

# Step 4: Transform the data
def transform_data(df):
    # Fill missing values in 'sales_amount' column with the mean
    df['sales_amount'].fillna(df['sales_amount'].mean(), inplace=True)

    # Use NumPy to apply advanced numerical transformations (e.g., log scaling)
    df['scaled_sales'] = np.log(df['sales_amount'] + 1)

    # Aggregate sales by region
    aggregated_data = df.groupby('region')['sales_amount'].sum().reset_index()
    
    return aggregated_data

# Step 5: Save the transformed data to CSV
def save_to_csv(aggregated_data, filename='aggregated_sales_data.csv'):
    aggregated_data.to_csv(filename, index=False)
    print(f"Data saved to {filename}")

# Main function to run the pipeline
def run_pipeline():
    try:
        # Connect to Snowflake
        conn = connect_to_snowflake()

        # Extract data
        data = extract_data(conn)

        # Load data into DataFrame
        df = load_data_to_dataframe(data)

        # Transform the data
        aggregated_data = transform_data(df)

        # Save the transformed data to CSV
        save_to_csv(aggregated_data)

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if 'conn' in locals():
            conn.close()

# Execute the pipeline
if __name__ == '__main__':
    run_pipeline()
