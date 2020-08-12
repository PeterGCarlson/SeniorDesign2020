import tkinter as tk
from tkinter import *
from PIL import Image, ImageTk

root = Tk()

window = Tk()
window.title("<Simulation Parameters>")
window.geometry('350x175')
lbl = Label(window, text="Preheat Temperature")
lbl2 = Label(window, text="Preheat Time")
lbl3 = Label(window, text="Dwell Temperature")
lbl4 = Label(window, text="Dwell Time")
lbl5 = Label(window, text="Initial Composition")
lbl.grid(column=0, row=2)
lbl2.grid(column=0, row=3)
lbl3.grid(column=0, row=4)
lbl4.grid(column=0, row=5)
lbl5.grid(column=0, row=6)
units1 = Label(window, text="°C")
units2 = Label(window, text="seconds")
units3 = Label(window, text="°C")
units4 = Label(window, text="seconds")
units5 = Label(window, text="weight% Gold")
units1.grid(column=2, row=2)
units2.grid(column=2, row=3)
units3.grid(column=2, row=4)
units4.grid(column=2, row=5)
units5.grid(column=2, row=6)
txt = Entry(window,width=10)
txt2 = Entry(window,width=10)
txt3 = Entry(window,width=10)
txt4 = Entry(window,width=10)
txt5 = Entry(window,width=10)
txt.grid(column=1, row=2)
txt2.grid(column=1, row=3)
txt3.grid(column=1, row=4)
txt4.grid(column=1, row=5)
txt5.grid(column=1, row=6)

def clicked():
    lbl.configure(text= res)
btn = Button(window, text="Submit", command=clicked)
btn.grid(column=1, row=7)
window.mainloop()


import os
pathToExecutable = (
    'C:/Octave/Octave-5.2.0/mingw64/bin/octave-cli.exe'
)
os.environ['OCTAVE_EXECUTABLE'] = pathToExecutable

from oct2py import Oct2Py
oc = Oct2Py()

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.pack(fill=BOTH, expand=1)
        self.create_widgets()

    def create_widgets(self):
        image = Image.open('SolderPlot.bmp')
        image2 = ImageTk.PhotoImage(image)
        img = Label(self, image=image2)
        img.image = image2
        img.place(x=0, y=0)

def main():
    app = Application(master=root)
    root.geometry("1200x900")
    app.mainloop()

if __name__ == "__main__":
    main()