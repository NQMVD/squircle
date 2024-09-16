use bevy::prelude::*;
use bevy::render::render_asset::RenderAssetUsages;
use bevy::sprite::MaterialMesh2dBundle;
use bevy_egui::{egui, EguiContexts, EguiPlugin};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugins(EguiPlugin)
        .insert_resource(SquircleParams {
            n: 4.0,
            size: 300.0,
            brightness_factor: 0.1,
            noise_mode: 0,
            shade: false,
        })
        .add_systems(Startup, setup)
        .add_systems(Update, (ui_system, update_squircle))
        .run();
}

#[derive(Resource)]
struct SquircleParams {
    n: f32,
    size: f32,
    brightness_factor: f32,
    noise_mode: usize,
    shade: bool,
}

#[derive(Component)]
struct Squircle {
    last_n: f32,
}

fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<ColorMaterial>>,
    squircle_params: Res<SquircleParams>,
) {
    commands.spawn(Camera2dBundle::default());

    let squircle_mesh = create_squircle_mesh(squircle_params.size, squircle_params.n);

    commands.spawn((
        MaterialMesh2dBundle {
            mesh: meshes.add(squircle_mesh).into(),
            material: materials.add(ColorMaterial::from(Color::srgb(0.2, 0.2, 0.2))),
            transform: Transform::from_translation(Vec3::new(0.0, 0.0, 0.0)),
            ..default()
        },
        Squircle {
            last_n: squircle_params.n,
        },
    ));
}

fn create_squircle_mesh(size: f32, n: f32) -> Mesh {
    let mut vertices = Vec::new();
    let mut indices = Vec::new();
    let mut normals = Vec::new();
    let mut uvs = Vec::new();

    let center = [0.0, 0.0, 0.0];
    vertices.push(center);
    normals.push([0.0, 0.0, 1.0]);
    uvs.push([0.5, 0.5]);

    let steps = 100;
    for i in 0..=steps {
        let angle = i as f32 * 2.0 * std::f32::consts::PI / steps as f32;
        let x = size / 2.0 * (angle.cos().abs().powf(2.0 / n)) * angle.cos().signum();
        let y = size / 2.0 * (angle.sin().abs().powf(2.0 / n)) * angle.sin().signum();
        vertices.push([x, y, 0.0]);
        normals.push([0.0, 0.0, 1.0]);
        uvs.push([(x / size + 1.0) / 2.0, (y / size + 1.0) / 2.0]);

        if i > 0 {
            indices.extend_from_slice(&[0, i, i + 1]);
        }
    }
    indices.extend_from_slice(&[0, steps + 1, 1]);

    let mut mesh = Mesh::new(
        bevy::render::render_resource::PrimitiveTopology::TriangleList,
        RenderAssetUsages::RENDER_WORLD,
    );
    mesh.insert_attribute(Mesh::ATTRIBUTE_POSITION, vertices);
    mesh.insert_attribute(Mesh::ATTRIBUTE_NORMAL, normals);
    mesh.insert_attribute(Mesh::ATTRIBUTE_UV_0, uvs);
    mesh.insert_indices(bevy::render::mesh::Indices::U32(indices));

    mesh
}

fn ui_system(mut contexts: EguiContexts, mut squircle_params: ResMut<SquircleParams>) {
    egui::Window::new("Squircle Parameters").show(contexts.ctx_mut(), |ui| {
        ui.add(egui::Slider::new(&mut squircle_params.n, 2.0..=10.0).text("Edgie"));
        ui.add(
            egui::Slider::new(&mut squircle_params.brightness_factor, 0.0..=5.0).text("Brightness"),
        );
        ui.add(egui::Slider::new(&mut squircle_params.noise_mode, 0..=4).text("Noise Mode"));
        ui.checkbox(&mut squircle_params.shade, "Shade");
    });
}

fn update_squircle(
    squircle_params: Res<SquircleParams>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut query: Query<(&Handle<Mesh>, &mut Squircle)>,
) {
    if let Ok((mesh_handle, mut squircle)) = query.get_single_mut() {
        if (squircle_params.n - squircle.last_n).abs() > 1e-6 {
            if let Some(mesh) = meshes.get_mut(mesh_handle) {
                *mesh = create_squircle_mesh(squircle_params.size, squircle_params.n);
                squircle.last_n = squircle_params.n;
            }
        }
    }
}
