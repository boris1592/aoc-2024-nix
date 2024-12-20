# I gave up

I spent an hour writing a solution for the second part in nix only to see that it might take 2 hours to compute the answer (even though there are only 140 \* 140 \* 1600 iterations). Wrote a solution in C++ in 5 mins and computed the answer in 500 ms. The pure FP spirit is dead right now. Here's the code:

```cpp
#include <cstdint>
#include <fstream>
#include <iostream>
#include <queue>
#include <utility>
#include <vector>

std::vector<std::vector<int>> bfs(const std::pair<int, int> &start,
                                  const std::vector<std::vector<bool>> &field) {
  std::vector<std::vector<int>> out(
      field.size(), std::vector<int>(field.front().size(), 1 << 30));
  std::queue<std::pair<int, int>> q;

  out[start.first][start.second] = 0;
  q.push(start);

  while (!q.empty()) {
    std::pair<int, int> curr = q.front();
    q.pop();
    int dist = out[curr.first][curr.second];

    for (uint8_t i = 0; i < 4; ++i) {
      int first = curr.first + ((i % 2) * 2 - 1) * (i < 2);
      int second = curr.second + ((i % 2) * 2 - 1) * (i >= 2);

      if (field[first][second] && out[first][second] == (1 << 30)) {
        out[first][second] = dist + 1;
        q.push({first, second});
      }
    }
  }

  return out;
}

int main() {
  std::vector<std::vector<bool>> field;
  std::pair<int, int> start, end;

  std::ifstream input("input");
  std::string line;
  int row = 0;

  while (std::getline(input, line)) {
    field.push_back(std::vector<bool>());

    for (int col = 0; col < line.size(); ++col) {
      char chr = line[col];
      field.back().push_back(chr != '#');

      if (chr == 'S') {
        start = {row, col};
      }

      if (chr == 'E') {
        end = {row, col};
      }
    }

    ++row;
  }

  std::vector<std::vector<int>> dist_start = bfs(start, field);
  std::vector<std::vector<int>> dist_end = bfs(end, field);
  int normal_min = dist_start[end.first][end.second];
  int answer = 0;

  for (int row = 0; row < field.size(); ++row) {
    for (int col = 0; col < field[row].size(); ++col) {
      if (!field[row][col]) {
        continue;
      }

      for (int row1 = row - 20; row1 <= row + 20; ++row1) {
        for (int col1 = col - 20; col1 <= col + 20; ++col1) {
          int dist = abs(row1 - row) + abs(col1 - col);

          if (dist > 20 || row1 < 0 || row1 >= field.size() || col1 < 0 ||
              col1 >= field[row1].size() || !field[row1][col1]) {
            continue;
          }

          int total = dist_start[row][col] + dist_end[row1][col1] + dist;
          int save = normal_min - total;

          if (save >= 100) {
            ++answer;
          }
        }
      }
    }
  }

  std::cout << answer;
  return 0;
}
```
