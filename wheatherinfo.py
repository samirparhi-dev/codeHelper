from flask import Flask, render_template
import requests
import matplotlib.pyplot as plt
from datetime import datetime
from io import BytesIO
import base64

app = Flask(__name__)

def fetch_weather_data(city):
    url = f'http://api.weatherapi.com/v1/current.json?key=&q={city}'
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return data
    else:
        print("Error fetching weather data:", response.status_code)
        return None

def plot_temperature(data):
    if data is None:
        return None

    timestamps = [datetime.strptime(data['location']['localtime'], '%Y-%m-%d %H:%M')]
    temperatures = [data['current']['temp_c']]

    plt.plot(timestamps, temperatures, marker='o')
    plt.title('Temperature of the Day in Bhubaneswar, Odisha')
    plt.xlabel('Time')
    plt.ylabel('Temperature (°C)')
    plt.grid(True)

    # Save the plot to a BytesIO object
    img = BytesIO()
    plt.savefig(img, format='png')
    img.seek(0)
    plt.close()

    # Encode the image as base64 string
    img_base64 = base64.b64encode(img.getvalue()).decode()

    return img_base64

@app.route('/')
def index():
    city = "Bhubaneswar, Odisha"
    weather_data = fetch_weather_data(city)
    if weather_data:
        temperature_plot = plot_temperature(weather_data)
        return render_template('index.html', temperature_plot=temperature_plot)
    else:
        return "Error fetching weather data"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
