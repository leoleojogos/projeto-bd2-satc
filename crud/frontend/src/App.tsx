import { BrowserRouter, Routes, Route } from "react-router";
import OrdemServicoList from "./pages/OrdemServicoList";
import OrdemServicoForm from "./pages/OrdemServicoForm";

export default function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<OrdemServicoList />} />
                <Route path="/nova" element={<OrdemServicoForm />} />
                <Route path="/editar/:id" element={<OrdemServicoForm />} />
            </Routes>
        </BrowserRouter>
    );
}
