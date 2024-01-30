import astropy
import numpy as np
import os.path
from astropy.io import fits


from matplotlib import pyplot as plt
from sys import argv


"""
OVERALL GOALS:
    -take in folder with fits, headers have what they are in them
    -group all darks together, bias together, etc.
    -take median of each pixel value within dark, bias, and flats and store into master array
    -use these three master arrays to get science frames for a fit
"""

def loadFits(inputPath):
  return fits.open(f'{inputPath}')[0]



inputPath=None

#takes in directory with fits files within. 
if __name__ == '__main__':
    print("not working rn whoops")
    try:
        inputPath=argv[1]
    except IndexError:
        print("No file path provided as argument to python script.\n Exiting")
        exit(0)
    

    darkDicionary=dict(None)
    flatDicionary=dict(None)
    lightDicionary=dict(None)
    #no dictonary for biases as they are time and filter independent
    biasFits=[]
    
    for root, dirs, files in os.walk(inputPath):
        for file in files:
            if file.endswith(".fits"):
                hdul=loadFits(os.path.join(root, file))
                time=hdul.header["EXPTIME"]

                #find the type of image, then find its exposure time. 
                #see if any other of that type of image have been saved for that time. if not, make a list for that time.abs
                #append list for that exposure time with current file

                if(hdul.header["FRAMETYP"]=="Light"):
                    if lightDicionary.get(f"{hdul.header['FILTER']}-{time}")==None:
                        lightDicionary[f"{hdul.header['FILTER']}-{time}"]=[]
                    lightDicionary[f"{hdul.header['FILTER']}-{time}"].append(hdul.data)

                elif(hdul.header["FRAMETYP"]=="Dark"):
                    if darkicionary.get(time)==None:
                        lightDicionary[time]=[]
                    darkDicionary[time].append(hdul.data)

                elif(hdul.header["FRAMETYP"]=="Flat"):
                    if flatDicionary.get(f"{hdul.header['FILTER']}-{time}")==None:
                        flatDicionary[f"{hdul.header['FILTER']}-{time}"]=[]
                    flatDicionary[f"{hdul.header['FILTER']}-{time}"].append(hdul.data)         
                
                elif(hdul.header["FRAMETYP"]=="Bias"):
                    biasFits.append(hdul.data)
        


    #Assumes all .fits are taken with same camera
    
    #TODO look in header and make sure they all are before storing into array! differnet cameras wtih different resolutions would break this/give back bad data


    #Take median of pixel in each dark frame in a list, combine them into a single master dark frame
    darkMasters=dict(None)
    for key in darkDicionary.keys():
        darkMasters[key]=np.median(darkDicionary[key],axis=0)

    #Take median of pixel in each flat frame in a list, combine them into a single master flat frame
    flatMasters=dict(None)
    for key in flatDicionary.keys():
        flatMasters[key]=np.median(flatDicionary[key],axis=0)

    #Take median of pixel in each bias frame, combine them into master bias frame
    biasMaster=np.median(biasFits,axis=0)

    #go trough all lights found and turn them into science frames

    scienceFrames=dict[None]

    for key in lightDicionary.keys():
        scienceFrames[key]=[]
        for lightFit in lightDicionary[key]:
            '''
            THINGS THAT NEED TO BE DONE:

                follow thing that we talked about at OBS group    


            '''
            scienceFrame=lightFit

            scienceFrames[key].append()

    exit(0)