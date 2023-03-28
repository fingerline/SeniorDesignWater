rivercoords = [
      800,
      757,
      691, 
      665, 
      633, 
      598, 
      577, 
      542, 
      502, 
      458, 
      415, 
      380, 
      338, 
      307,
]
def scale(number):
    return round((number - 307) * (700) / (800 - 307) + 100)
newvals = [scale(x) for x in rivercoords]
print(newvals)