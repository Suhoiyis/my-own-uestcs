import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import DBSCAN
import re


plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

file_path = 'data.txt'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    numbers = re.findall(r'[-+]?\d*\.\d+e[-+]\d+', content)
    data_list = [float(num) for num in numbers]
    if len(data_list) % 2 != 0:
        data_list = data_list[:-1]
    data = np.array(data_list).reshape(-1, 2)

    # eps=0.1: 定义一个点的邻域半径为0.1。
    # min_samples=5: 定义一个核心点周围至少需要有5个点才能形成一个簇。

    db = DBSCAN(eps=0.1, min_samples=5)

    # 执行聚类，获取每个点的标签
    labels = db.fit_predict(data)


    # 获取所有唯一的簇标签。-1 代表噪声点。
    unique_labels = set(labels)

    # 计算发现的簇的数量（不包括噪声）
    n_clusters_ = len(unique_labels) - (1 if -1 in labels else 0)
    n_noise_ = list(labels).count(-1)

    print(f'成功使用 DBSCAN 完成聚类。')
    print(f'发现的簇数量: {n_clusters_}')
    print(f'识别的噪声点数量: {n_noise_}')

    plt.figure(figsize=(10, 8))

    #为每个簇和噪声点设置不同的颜色
    colors = [plt.cm.Spectral(each) for each in np.linspace(0, 1, len(unique_labels))]

    for k, col in zip(unique_labels, colors):
        if k == -1:
            # 将噪声点设置为黑色
            col = [0, 0, 0, 1]

        class_member_mask = (labels == k)

        xy = data[class_member_mask]
        plt.plot(xy[:, 0], xy[:, 1], 'o', markerfacecolor=tuple(col),
                markeredgecolor='k', markersize=7, label=f'簇 {k}' if k != -1 else '噪声点')

    plt.title(f'DBSCAN 聚类结果 (共 {n_clusters_} 个簇)')
    plt.xlabel('X 坐标')
    plt.ylabel('Y 坐标')
    plt.legend()
    plt.grid(True)

    plt.savefig('dbscan_output.png')
    print("聚类结果图像已保存为 dbscan_output.png")

except FileNotFoundError:
    print(f"错误：无法找到文件 '{file_path}'。")
except Exception as e:
    print(f"处理文件时发生错误: {e}")