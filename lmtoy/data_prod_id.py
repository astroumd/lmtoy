#! /usr/bin/env python3
#

"""Code to generate LMTOY data product reference ID."""

import hashlib
import itertools
import base64

def _make_unique_id(obsnums, is_sorted=False):
    """Return a unique string for a list of obsnums."""
    if not is_sorted:
        obsnums = sorted(set(obsnums))
    data = '_'.join(map(str, obsnums))
    if True:
        hash_object = hashlib.sha256(data.encode())
        unique_id = base64.b32encode(hash_object.digest()).decode()
    else:
        hash_object = hashlib.sha256(data.encode())
        unique_id = hash_object.hexdigest()

    return unique_id

def make_lmtoy_data_prod_id(obsnums, n=-1, hash_len=7):
    """Return the reference ID for lmtoy data product
       
    Input:
         obnums      a list of obsnums
         n           used during testing, ignore now
         hash_len    number of digits to use in the hash
    """
    # make
    obsnums = sorted(set(obsnums))
    n_obs = len(obsnums)
    if n_obs == 0:
        raise ValueError("list of obsnums cannot be empty.")
    obsnum0 = obsnums[0]
    obsnum1 = obsnums[n_obs-1]
    if n_obs == 1:
        #return f"o{obsnum0}s"     # toltec single
        return f"{obsnum0}"  
    uid = _make_unique_id(obsnums, is_sorted=True)
    #return f"o{obsnum0}_c{n_obs}_{uid[:hash_len]}"        # toltec combo
    #return f"{obsnum0}_{obsnum1}_{uid[:hash_len]}_{n}"
    return f"{obsnum0}_{obsnum1}_{uid[:hash_len]}"

if __name__ == '__main__':

    obsnums = [
        102284, 102295, 102297, 102333, 102336, 102365, 102369,
        102373, 102381, 102384, 102386, 102411, 102413, 102486,
        102489, 102511, 102516, 102580, 102586, 102599, 102604
    ]
    dpid = make_lmtoy_data_prod_id([obsnums[0]])
    print(f"Data product ID: {dpid} (single)")    
    
    dpid = make_lmtoy_data_prod_id(obsnums,0)
    print(f"Data product ID: {dpid} (full combo)") 
    test0 = dpid[:13]

    print("Subsets:")
    check_collision = []
    n0 = 2
    n1 = len(obsnums)
    # n0 = n1-1          # zhiyuan
    for n in range(n0,n1):
        for ss in itertools.combinations(obsnums, n):
            dpid = make_lmtoy_data_prod_id(ss,n)
            if True:
                if dpid[:13] != test0:
                    continue
            print(f"  Data product ID: {dpid}")
            check_collision.append(dpid)

    n1 = len(check_collision)
    n2 = len(set(check_collision))
    if n1 != n2:
        print("Collisions found!",n1,n1-n2)
    else:
        print("No collision in ",n1)
        
