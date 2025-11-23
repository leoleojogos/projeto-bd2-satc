import axios from "axios";

const api = axios.create({
    baseURL: "http://localhost:3000/ordem-servico",
});

export interface OrdemServico {
    id_os?: number;
    id_veiculo: number;
    id_mecanico: number;
    data_entrada?: string | null;
    data_saida?: string | null;
    status?: string | null;
    observacoes?: string | null;
}

export const ordemServicoApi = {
    getAll: () => api.get<OrdemServico[]>("/"),
    getById: (id: number) => api.get<OrdemServico>(`/${id}`),
    create: (data: OrdemServico) => api.post("/", data),
    update: (id: number, data: OrdemServico) => api.put(`/${id}`, data),
    remove: (id: number) => api.delete(`/${id}`),
};
