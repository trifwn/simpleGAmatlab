import numpy as np
import pandas as pd
import tensorflow as tf

gpus = tf.config.experimental.list_physical_devices('GPU')
if gpus:
    try:
        # Currently, memory growth needs to be the same across GPUs
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        logical_gpus = tf.config.experimental.list_logical_devices('GPU')
    except RuntimeError as e:
        # Memory growth must be set before GPUs have been initialized
        print(e)
tf.test.is_built_with_cuda()

CASE = ['Rough','UTS','Elon']
target = ['roughness (μm)','tension_strength (MPa)','elongation (%)']

def loadAndRunANN(index,data):
    df = data.copy(deep=True)  
    lossfns = [tf.keras.losses.MeanSquaredError(),tf.keras.losses.MeanAbsolutePercentageError(),tf.keras.losses.MeanAbsoluteError()]
    optimizers = [tf.keras.optimizers.Adam(learning_rate=i,beta_1=0.09,beta_2=0.9) for i in [5e-2,1e-2,5e-3]]
    metrics = ['mean_squared_error','mean_absolute_error',tf.keras.losses.MeanAbsolutePercentageError()]
    optimizer = optimizers[index]
    lossfn = lossfns[index]

    # Normalize data
    cols_to_norm = ['layer_height (mm)', 'wall_thickness (mm)', 'infill_density (%)',
                 'nozzle_temperature (0C)', 'print_speed (mm/s)', 'fan_speed (%)']
    lb = [0.02,1 ,10,200,40 , 0]
    ub = [0.2 ,10,90,250,120, 100]
    for i,colname in enumerate(cols_to_norm):
        df[colname] = df[colname].apply(lambda x: -1 + 2*(x - lb[i]) / (ub[i] - lb[i])).astype(np.float32)

    # Choose Data to Train
    cols2go = []
    cols2go.append(['print_speed (mm/s)','fan_speed (%)','wall_thickness (mm)',
        'pla','abs','nozzle_temperature (0C)','layer_height (mm)'])

    cols2go.append(['fan_speed (%)','print_speed (mm/s)','pla','abs','layer_height (mm)',
                'infill_density (%)','wall_thickness (mm)','nozzle_temperature (0C)'])

    cols2go.append(['fan_speed (%)','pla','abs','layer_height (mm)','nozzle_temperature (0C)',
                    'wall_thickness (mm)','infill_density (%)'])
    cols = cols2go[index]
    x = df[(i for i in cols)]
    model = tf.keras.models.load_model(CASE[index]+'model.h5',compile=False)
    model.compile(
        optimizer = optimizer,
        loss = lossfn,
        metrics = metrics
    )
    ypred = model.predict(x,verbose=0).squeeze()
    return ypred

def prediction(df):
    classes = ['layer_height (mm)','wall_thickness (mm)','infill_density (%)','nozzle_temperature (0C)','print_speed (mm/s)','pla','abs', 'fan_speed (%)']
    dict = {}
    df = np.array(df)
    if  df.ndim == 1:
        ypred = np.empty(3)
        for i,name in enumerate(classes):
            dict[name] = list()
            dict[name].append(df[i])
    else:
        ypred = np.empty((len(df),3))
        for i,name in enumerate(classes):
            dict[name] = list()
            for item in df[:,i]:
                dict[name].append(item)
    df = pd.DataFrame(dict) 
    for index,name in enumerate(['Rmodel','Umodel','Emodel']):
        if  ypred.ndim == 1:
            ypred[index] = loadAndRunANN(index,df)
        else:
            ypred[:,index] = loadAndRunANN(index,df)
    return ypred

z = prediction(df)