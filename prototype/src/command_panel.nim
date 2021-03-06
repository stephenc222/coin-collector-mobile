from strutils import rsplit, parseInt, strip, find, toUpperAscii

include game_data

proc renderCommandPanel*(): GameCoordinate =
  stdout.write "Enter Coordinate To Check(Y,X): "
  while true:
    let yxInput = readLine(stdin).toUpperAscii

    if (find(yxInput , "(") != -1 or find(yxInput , ")") != -1):
      echo "please enter only comma separated numbers"
      continue

    # should only have two values, which are numbers
    let sepValues = rsplit(yxInput, ',')

    if len(sepValues) != 2:
      echo "please only enter two values, a letter and a number"
      continue

    # fails if sepValues[1] is a non-alphanumeric character, e.g., "$,%,^"
    let yVal = int(yxInput[0])
    let xVal = parseInt(strip(sepValues[1], true))

    if (yVal < 65 or yVal > 74):
      echo "Y must be between A and J"
      continue

    if (xVal < 0 or xVal > 9):
      echo "X must be between 0 and 9"
      continue

    result = (xVal, yVal - 65)
    break

when isMainModule:
  let test = renderCommandPanel()
  echo "test:", test
