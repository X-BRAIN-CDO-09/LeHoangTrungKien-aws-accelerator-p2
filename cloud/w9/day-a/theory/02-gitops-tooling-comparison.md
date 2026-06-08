# 02 - Công cụ GitOps và mô hình Pull-based Deployment

## Cách hiểu GitOps

GitOps có thể hiểu đơn giản là: muốn cluster chạy như thế nào thì mô tả trạng thái đó trong Git. Cluster không được xem là nơi cấu hình chính, mà chỉ là nơi hiện thực hóa những gì đã được khai báo.

Thay vì một người chạy lệnh apply thủ công, một controller trong cluster sẽ theo dõi repo và tự điều chỉnh tài nguyên. Nếu Git thay đổi, cluster thay đổi theo. Nếu cluster bị sửa tay khác với Git, controller có thể phát hiện và đưa nó về trạng thái đúng.

## Hai cách đưa thay đổi vào cluster

| Mô hình | Cách hoạt động | Rủi ro chính |
| --- | --- | --- |
| Push | CI/CD đứng bên ngoài cluster và đẩy manifest vào Kubernetes. | CI/CD cần quyền truy cập mạnh vào cluster. |
| Pull | Agent chạy trong cluster, tự kéo cấu hình từ Git về. | Cần vận hành thêm GitOps controller trong cluster. |

Trong mô hình push, pipeline phải giữ kubeconfig hoặc credential để gọi Kubernetes API. Cách này dễ hiểu và quen thuộc, nhưng nếu credential bị lộ thì cluster có nguy cơ bị tác động từ bên ngoài.

Trong mô hình pull, ArgoCD hoặc Flux chạy bên trong cluster. Controller đọc Git rồi tự apply thay đổi. CI/CD không cần cầm quyền admin để truy cập cluster, nhờ đó ranh giới bảo mật rõ hơn.

## Drift Reconciliation

Một điểm rất hay của GitOps là phát hiện drift. Drift xảy ra khi trạng thái thực tế trong cluster khác với trạng thái trong Git.

Ví dụ, nếu ai đó chạy:

```bash
kubectl edit deployment demo-app -n demo
```

ArgoCD có thể nhận ra Deployment đã khác manifest trong Git. Tùy cấu hình, ArgoCD sẽ báo `OutOfSync` hoặc tự sửa lại bằng `selfHeal`.

## Nhìn nhanh ArgoCD và Flux

| Tiêu chí | ArgoCD | Flux |
| --- | --- | --- |
| Cách quan sát | Mạnh về UI, dễ nhìn thấy cây resource và trạng thái sync. | Thiên về CLI và automation, cảm giác gọn hơn. |
| Cách tổ chức | Xoay quanh khái niệm Application. | Bám sát Kubernetes custom resources. |
| Trải nghiệm học | Dễ học với người mới vì nhìn được luồng sync bằng giao diện. | Hợp với người đã quen GitOps/Kubernetes và thích cấu hình tối giản. |
| Hệ sinh thái liên quan | Đi cùng Argo Rollouts, Argo Workflows. | Hay đi cùng Flagger và các controller nhỏ gọn. |
| Trường hợp phù hợp | Demo, training, platform cần UI quản trị rõ ràng. | Cluster cần automation cao, ít phụ thuộc UI. |

## Vì sao lab chọn ArgoCD?

Với mục tiêu học W9, ArgoCD dễ dùng hơn vì có giao diện để quan sát app đang `Synced`, `OutOfSync`, `Healthy` hay `Degraded`. Khi mới học GitOps, việc nhìn thấy resource tree trên UI giúp hiểu nhanh hơn so với chỉ đọc log hoặc CLI.

Flux vẫn là lựa chọn tốt trong thực tế, nhất là khi team muốn một cách tiếp cận nhẹ, tự động hóa mạnh và gần với Kubernetes-native hơn.

## Kết luận

Điều cần nắm không phải chỉ là ArgoCD hay Flux tốt hơn, mà là tư duy GitOps: Git giữ cấu hình chuẩn, controller kéo thay đổi vào cluster, và drift cần được phát hiện hoặc sửa tự động.
