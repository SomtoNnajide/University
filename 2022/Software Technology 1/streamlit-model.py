"""
Project: Simple linear regression model
Author: Somtochukwu Nnajide
Libraries: 
    1. Statistics 
    2. Streamlit
    3. Numpy
    4. Pandas
    5. Matplotlib

    All libraries need to be installed 
"""

from statistics import correlation
import streamlit as st
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
  
def estimate_coef(x, y):
    # number of observations/points
    n = np.size(x)
  
    # mean of x and y vector
    m_x = np.mean(x)
    m_y = np.mean(y)
  
    # calculating cross-deviation and deviation about x
    SS_xy = np.sum(y*x) - n*m_y*m_x
    SS_xx = np.sum(x*x) - n*m_x*m_x
  
    # calculating regression coefficients
    b_1 = SS_xy / SS_xx
    b_0 = m_y - b_1*m_x
  
    return (b_0, b_1)
  
def plot_regression_line(x, y, b, sColor, lColor, bColor, xlabel, ylabel):
    #background color
    plt.axes().set_facecolor(bColor)

    # plotting the actual points as scatter plot
    plt.scatter(x, y, color = sColor,
               marker = "o", s = 30)
  
    # predicted response vector
    y_pred = b[0] + b[1]*x
  
    # plotting the regression line
    plt.plot(x, y_pred, color = lColor)
  
    # putting labels
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
  
    # function to show plot
    st.pyplot(plt)

def pearson_coeff(arr1, arr2):
    #determine pearson correlation
    return correlation(arr1,arr2)

def coeff_of_determination(coeff):
    #determine r-square value
    return coeff ** 2

def description():
    #brief description of the prgoram
    st.title("Linear Regression model")
    st.subheader("Decription")
    st.write("This app visualises a simple linear regression model between 2 quantitative samples\n")
    st.write("Use the color picker to change the colors of the scatter plot or line")
    st.write("Make predictions using the prediction tool given")

def text_input(label, placeholder):
    #return text widgets
        input = st.text_input(
            label = label,
            label_visibility= "visible",
            disabled = False,
            placeholder = placeholder)

        return input
  
def get_excel_file():

    #upload excel file and read into dataframe
    excelFile = st.file_uploader("Select an Excel file", type='xlsx')
    
    try:    
        df = pd.read_excel(excelFile)
    except ValueError:
        st.error("Please choose an Excel file", icon="🚨")
    else:
        st.write(df)
        xVar = text_input("Enter column name","Explanatory variable (x)")
        yVar = text_input("Enter column name","response variable (y)")

        return df, xVar, yVar

def change_color():
    #change plot colors
    st.subheader("Change Color")

    col1, col2, col3 = st.columns(3)

    with col1:
        sColor = st.color_picker("Change scatter color", '#27c1f5')
    with col2:
        lColor = st.color_picker("Change line color", '#d6230f')
    with col3:
        bColor = st.color_picker("Change plot background color", '#3b3934')

    return sColor, lColor, bColor

def results(intercept, slope, pearson, rSquare, xVar, yVar):
    #output calculated results

    data = {
        "Intercept": round(intercept,4),
        "Slope": round(slope,4),
        "Pearson coefficient": round(pearson,2),
        "R-square value": round(rSquare,4)
    }

    st.write(pd.DataFrame(data, index=["1"]))

    st.write(f"Model: {yVar} = {round(intercept,4)} + {round(slope,4)} * {xVar}")

def make_prediction(x,y, intercept, slope):
    #make response predictions given the explanatory variable
    st.subheader(f"Predict {y} from {x}")
    var = st.number_input(f"Predict {y}")

    yPredict = intercept + (slope*var)
    st.write(f"{y} Prediction = {round(yPredict,4)}")

def main():
    description()
    #nested try-excepts for error handling and maintaining program flow

    try:
        df, xVar, yVar = get_excel_file()
    except TypeError:
        pass
    else:
        try:
            #convert select columns into numpy array
            x = df[xVar].to_numpy()
            y = df[yVar].to_numpy()
        except KeyError:
            st.error("Make sure column names are identical", icon="🚨")
        else:
            # estimating coefficients
            try:
                b = estimate_coef(x, y)
            except TypeError:
                st.error("Make sure column values are numeric", icon="🚨")
            else:
                #get coeefficients
                pearson = pearson_coeff(x,y)
                rSquare = coeff_of_determination(pearson)

                #change colors
                scatterColor, lineColor, bgColor = change_color()

                # plotting regression line
                plot_regression_line(x, y, b, scatterColor, lineColor, bgColor, xVar, yVar)

                #get results
                results(b[0], b[1], pearson, rSquare, xVar.upper(), yVar.upper())

                #make predictions
                make_prediction(xVar, yVar, round(b[0],4), round(b[1],4))

if __name__ == "__main__":
    main()
