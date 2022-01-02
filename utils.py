#
# utility function to support the operation of notebooks for
# creating, operating, scaling and scoring mpd test sets and 
# solutions

import os
import json
import pandas as pd
import itertools

def process_mpd(path, quick=False, maxfiles=10, debug=False, progress=True):
    """
    Load the mpd training set slice files.
    Takes path to slice files.
    Optional quick processing by selecting maxfiles subset of slice files.
    Optionally produce debug telemetry
    Default to printing progress at every 100 files.

    Code adapted for pandas from the utilities provided with the training set. 
    
    Fast load of data frames using dataframe concat method instead of append
    https://stackoverflow.com/a/65916822/8928529
    """
    plfiles = [] # an empty list to store the data frames
    trfiles = []
    count = 0
    global playlists
    global tracks
    
    filenames = os.listdir(path)
    for filename in sorted(filenames):
        if filename.startswith("mpd.slice.") and filename.endswith(".json"):

            fullpath = os.sep.join((path, filename))

            if debug: print("loading {}: in: {}".format(filename, path))
            if debug: print("file {}:".format(fullpath))

            f = open(fullpath)
            js = f.read()
            f.close()
            if debug: print("loaded {}:".format(fullpath))
            mpd_slice = json.loads(js)
            
            #mpd_slice = pd.read_json(f, lines=False) # read data frame from json file
            #f.close()
            
            if debug: print("loaded {}:".format(fullpath))
    
            #dfs.append(data) # append the data frame to the list
            slice_info = pd.json_normalize(mpd_slice, record_path=['info'])
            slice_name = slice_info['slice']
            slice_playlists = pd.json_normalize(mpd_slice, record_path=['playlists'])
            slice_playlists["slice"] = slice_name
            if debug: print("slice length {}:".format(len(slice_playlists)))
            slice_tracks = pd.json_normalize(mpd_slice['playlists'], record_path=['tracks'], meta=['pid'])
            # drop tracks from playlist dataframe
            # not worth it to save space, just makes it harder to reconstruct the playlist
            #slice_playlists.drop(columns='tracks', inplace=True)
            plfiles.append(slice_playlists)
            trfiles.append(slice_tracks)
            count += 1
            
        if progress and (count % 100 == 0):
            print("Files loaded: {}".format(count))

        if quick and count > maxfiles:
            break

            
    playlists = pd.concat(plfiles) #, ignore_index=True) # concatenate all the data frames in the list.
    playlists.reset_index(drop=True, inplace=True)
    tracks = pd.concat(trfiles) #, ignore_index=True) # concatenate all the data frames in the list.
    tracks.reset_index(drop=True, inplace=True)
    
    return playlists, tracks

def convert_to_64bit_indices(A):
    """
    Convert to 64bit index to avoid "RuntimeError: nnz of the result is too large"
    https://github.com/scipy/scipy/issues/12495#issuecomment-654439994

    This was preventing the creation of matrices beyond about 30k x 30k.
    """
    A.indptr = np.array(A.indptr, copy=False, dtype=np.int64)
    A.indices = np.array(A.indices, copy=False, dtype=np.int64)
    return A

def sort_csr(m):
    """
    sort track score pairs from a sparse matrix by the score rather than index

    used to sort the ouput of recommendation scores in score order.
    """
    tuples = zip(m.indices, m.data)
    return sorted(tuples, key=lambda x: (x[1]), reverse=True)

