<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8"/>
		<title>Settings Demo: Linux Academy: Microsoft Azure Exam 70-533 Prep</title>
		<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
	</head>
	<body>
		<div class="container">
			<div class="row">
				<div class="col-md-12">
					<h2>Settings Demo: Linux Academy: Microsoft Azure Exam 70-533 Prep</h2>
					<p>This PHP page shows the settings in this Azure Web App.</p>
					<table class="table table-striped">
						<thead>
							<tr>
								<th>Setting Name</th>
								<th>Setting Type</th>
								<th>Setting Value</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td>WEBSITE_HOSTNAME</td>
								<td>Environment-provided, global constant</td>
								<td><?php echo getenv("WEBSITE_HOSTNAME"); ?></td>
							</tr>
							<tr>
								<td>slotMessage</td>
								<td>Slot setting</td>
								<td><?php echo getenv("slotMessage"); ?></td>
							</tr>
							<tr>
								<td>apiKey</td>
								<td>Slot setting</td>
								<td><?php echo getenv("apiKey"); ?></td>
							</tr>
							<tr>
								<td>DefaultConnectionString</td>
								<td>Global connection string</td>
								<td><?php echo getenv("SQLAZURECONNSTR_DefaultConnectionString"); ?></td>
							</tr>
							<tr>
								<td>SlotConnectionString</td>
								<td>Slot-specific connection string</td>
								<td><?php echo getenv("SQLAZURECONNSTR_SlotConnectionString"); ?></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</body>
</html>