import { useEffect, useState } from "react";
import { ordemServicoApi, type OrdemServico } from "../api/ordemServicoApi";
import { useNavigate } from "react-router";

export default function OrdemServicoList() {
    const [ordens, setOrdens] = useState<OrdemServico[]>([]);
    const navigate = useNavigate();

    const carregar = async () => {
        const response = await ordemServicoApi.getAll();
        setOrdens(response.data);
    };

    const deletar = async (id: number) => {
        if (confirm("Deseja realmente excluir?")) {
            await ordemServicoApi.remove(id);
            carregar();
        }
    };

    useEffect(() => {
        carregar();
    }, []);

    return (
        <div className="p-8 max-w-5xl mx-auto">
            <h1 className="text-3xl font-bold mb-6">Ordens de Serviço</h1>

            <button
                onClick={() => navigate("/nova")}
                className="cursor-pointer mb-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
                + Nova Ordem
            </button>

            <div className="overflow-x-auto shadow rounded-lg">
                <table className="min-w-full text-left border">
                    <thead className="bg-gray-100 border-b">
                        <tr>
                            <th className="p-3">ID</th>
                            <th className="p-3">Veículo</th>
                            <th className="p-3">Mecânico</th>
                            <th className="p-3">Status</th>
                            <th className="p-3">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        {ordens.map((os) => (
                            <tr key={os.id_os} className="border-b hover:bg-gray-50">
                                <td className="p-3">{os.id_os}</td>
                                <td className="p-3">{os.id_veiculo}</td>
                                <td className="p-3">{os.id_mecanico}</td>
                                <td className="p-3">{os.status || "-"}</td>
                                <td className="p-3 flex gap-2">
                                    <button
                                        onClick={() => navigate(`/editar/${os.id_os}`)}
                                        className="px-3 py-1 text-sm bg-yellow-500 text-white rounded hover:bg-yellow-600"
                                    >
                                        Editar
                                    </button>
                                    <button
                                        onClick={() => deletar(os.id_os!)}
                                        className="px-3 py-1 text-sm bg-red-600 text-white rounded hover:bg-red-700"
                                    >
                                        Deletar
                                    </button>
                                </td>
                            </tr>
                        ))}

                        {ordens.length === 0 && (
                            <tr>
                                <td colSpan={5} className="p-4 text-center text-gray-500">
                                    Nenhuma ordem encontrada.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
