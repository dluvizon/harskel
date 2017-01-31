#!/usr/bin/python3

from keras.models import Sequential
from keras.layers import Dense, Dropout
import numpy as np

xtr = np.loadtxt('../output/data/csv/data_x.csv', delimiter=',')
xte = np.loadtxt('../output/data/csv/data_y.csv', delimiter=',')
#xtr = np.loadtxt('../output/data/csv/data_Lx.csv', delimiter=',')
#xte = np.loadtxt('../output/data/csv/data_Ly.csv', delimiter=',')

ytr = np.loadtxt('../output/data/csv/label_x.csv', delimiter=',')
yte = np.loadtxt('../output/data/csv/label_y.csv', delimiter=',')

model = Sequential()
model.add(Dense(256, activation='relu', input_dim=xtr.shape[1]))
model.add(Dropout(0.7))
model.add(Dense(ytr.shape[1], activation='softmax'))
model.compile(optimizer='rmsprop',
              loss='categorical_crossentropy',
              metrics=['accuracy'])
model.summary()

hist = model.fit(xtr, ytr, nb_epoch=100)
acc = model.evaluate(xte, yte)
print (acc)

